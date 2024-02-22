function loadIALiRTData(this, primaryMetaData, secondaryMetaData)
    %% Import Data

    if isempty(this.IALiRTFileNames)
        return;
    end

    primaryMetaData = primaryMetaData.copy();
    primaryMetaData.set(Mode = "I-ALiRT", DataFrequency = 1/4, PacketFrequency = 4);

    secondaryMetaData = secondaryMetaData.copy();
    secondaryMetaData.set(Mode = "I-ALiRT", DataFrequency = 1/4, PacketFrequency = 4);

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

        % Add compression and quality flags.
        primary.compression = false(height(primary), 1);
        secondary.compression = false(height(secondary), 1);

        primary.quality = true(height(primary), 1);
        secondary.quality = true(height(secondary), 1);

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

    for is = this.IALiRTProcessing

        primaryData = is.apply(primaryData, primaryMetaData);
        secondaryData = is.apply(secondaryData, secondaryMetaData);
    end

    %% Assign Values

    this.Results.IALiRT = mag.IALiRT(mag.Science(primaryData, primaryMetaData), mag.Science(secondaryData, secondaryMetaData));
end
