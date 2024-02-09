function loadIALiRTData(this, primaryMetaData, secondaryMetaData)
    %% Import Data

    if isempty(this.IALiRTFileNames)
        return;
    end

    primaryMetaData = primaryMetaData.copy();
    primaryMetaData.set(Mode = "I-ALiRT", DataFrequency = 1/8, PacketFrequency = 8);

    secondaryMetaData = secondaryMetaData.copy();
    secondaryMetaData.set(Mode = "I-ALiRT", DataFrequency = 1/8, PacketFrequency = 8);

    [~, ~, extension] = fileparts(this.IALiRTPattern);
    rawIALiRT = this.dispatchExtension(extension, ImportFileNames = this.IALiRTFileNames).import();

    primaryData = timetable.empty();
    secondaryData = timetable.empty();

    for i = 1:numel(rawIALiRT)
        %% Split Data

        idxKeep = 1:size(rawIALiRT{i}, 2);
        variableNames = rawIALiRT{i}.Properties.VariableNames;

        % Retrieve primary.
        locPrimaryKeep = contains(variableNames, ["pri", "sequence"]);
        primary = rawIALiRT{i}(:, idxKeep(locPrimaryKeep));

        % Retrieve secondary.
        locSecondaryKeep = contains(variableNames, ["sec", "sequence"]);
        secondary = rawIALiRT{i}(:, idxKeep(locSecondaryKeep));

        %% Process Data

        % Rename variables.
        newVariableNames = ["x", "y", "z", "range", "coarse", "fine"];

        primary = renamevars(primary, ["x_pri", "y_pri", "z_pri", "rng_pri", "pri_coarse", "pri_fine"], newVariableNames);
        secondary = renamevars(secondary, ["x_sec", "y_sec", "z_sec", "rng_sec", "sec_coarse", "sec_fine"], newVariableNames);

        % Current file meta data.
        pmd = primaryMetaData.copy();
        smd = secondaryMetaData.copy();

        % Apply processing steps.
        for ps = this.PerFileProcessing

            primary = ps.apply(primary, pmd);
            secondary = ps.apply(secondary, smd);
        end

        % Remove last data point, to avoid continuous lines when data is
        % missing.
        primary{end, ["x", "y", "z"]} = missing();
        secondary{end, ["x", "y", "z"]} = missing();

        %% Convert to timetable

        primaryData = vertcat(primaryData, table2timetable(primary, RowTimes = "t")); %#ok<AGROW>
        secondaryData = vertcat(secondaryData, table2timetable(secondary, RowTimes = "t")); %#ok<AGROW>
    end

    %% Amend Timestamp

    startTime = bounds(primaryData.t);

    if numel(rawIALiRT) == 1

        primaryMetaData = pmd;
        secondaryMetaData = smd;
    end

    primaryMetaData.Timestamp = startTime;
    secondaryMetaData.Timestamp = startTime;

    %% Add Mode and Range Change Events

    emptyTime = datetime.empty();
    emptyTime.TimeZone = "UTC";

    sensorEvents = struct2table(struct(Time = emptyTime, ...
        Mode = double.empty(0, 1), ...
        PrimaryRate = double.empty(0, 1), ...
        SecondaryRate = double.empty(0, 1), ...
        PacketFrequency = double.empty(0, 1), ...
        Duration = double.empty(0, 1), ...
        Range = double.empty(0, 1), ...
        Sensor = string.empty(0, 1), ...
        Label = string.empty(0, 1)));
    sensorEvents = table2timetable(sensorEvents, RowTimes = "Time");

    primaryData.Properties.Events = this.generateEventTable("Primary", sensorEvents, primaryData);
    secondaryData.Properties.Events = this.generateEventTable("Secondary", sensorEvents, secondaryData);

    %% Process Data as a Whole

    for ps = this.WholeDataProcessing

        primaryData = ps.apply(primaryData, primaryMetaData);
        secondaryData = ps.apply(secondaryData, secondaryMetaData);
    end

    %% Process Science Data

    for ss = this.ScienceProcessing

        primaryData = ss.apply(primaryData, primaryMetaData);
        secondaryData = ss.apply(secondaryData, secondaryMetaData);
    end

    %% Assign Values

    this.Results.IALiRT = mag.IALiRT(mag.Science(primaryData, primaryMetaData), mag.Science(secondaryData, secondaryMetaData));
end
