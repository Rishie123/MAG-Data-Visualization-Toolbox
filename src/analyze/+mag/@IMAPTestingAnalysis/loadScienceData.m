function loadScienceData(this, primaryMetaData, secondaryMetaData)
    %% Import Data

    if isempty(this.ScienceFileNames)
        return;
    end

    [~, ~, extension] = fileparts(this.SciencePattern);
    rawScience = this.dispatchExtension(extension, ImportFileNames = this.ScienceFileNames).import();

    primaryData = timetable.empty();
    secondaryData = timetable.empty();

    for i = 1:numel(rawScience)
        %% Split Data

        primary = rawScience{i}(:, regexpPattern(".*(pri|sequence).*"));
        secondary = rawScience{i}(:, regexpPattern(".*(sec|sequence).*"));

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
        [mode, primaryFrequency, secondaryFrequency, packetFrequency] = extractFileMetaData(this.ScienceFileNames(i));

        pmd = primaryMetaData.copy();
        pmd.set(Mode = mode, DataFrequency = primaryFrequency, PacketFrequency = packetFrequency);

        smd = secondaryMetaData.copy();
        smd.set(Mode = mode, DataFrequency = secondaryFrequency, PacketFrequency = packetFrequency);

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

    [startTime, endTime] = bounds(primaryData.t);

    if numel(rawScience) == 1

        primaryMetaData = pmd;
        secondaryMetaData = smd;
    end

    primaryMetaData.Timestamp = startTime;
    secondaryMetaData.Timestamp = startTime;

    %% Add Mode and Range Change Events

    sensorEvents = timetable(this.Results.Events);
    sensorEvents = sensorEvents(timerange(startTime - seconds(1), endTime, "closed"), :);

    primaryData.Properties.Events = this.generateEventTable("Primary", sensorEvents, primaryData);
    secondaryData.Properties.Events = this.generateEventTable("Secondary", sensorEvents, secondaryData);

    %% Process Data as a Whole

    for ps = this.WholeDataProcessing

        primaryData = ps.apply(primaryData, primaryMetaData);
        secondaryData = ps.apply(secondaryData, secondaryMetaData);
    end

    %% Extract Ramp Mode (If Any)

    % Determine ramp mode times.
    primaryRampPeriod = findRampModePeriod(primaryData.Properties.Events);
    secondaryRampPeriod = findRampModePeriod(secondaryData.Properties.Events);

    primaryRampMode = primaryData(primaryRampPeriod, :);
    secondaryRampMode = secondaryData(secondaryRampPeriod, :);

    primaryData(primaryRampPeriod, :) = [];
    secondaryData(secondaryRampPeriod, :) = [];

    if ~isempty(primaryRampMode) && ~isempty(secondaryRampMode)

        % Process ramp mode.
        for rs = this.RampProcessing

            primaryRampMode = rs.apply(primaryRampMode, primaryMetaData);
            secondaryRampMode = rs.apply(secondaryRampMode, secondaryMetaData);
        end

        % Assign ramp mode.
        this.PrimaryRamp = mag.Science(primaryRampMode, primaryMetaData);
        this.SecondaryRamp = mag.Science(secondaryRampMode, secondaryMetaData);
    end

    %% Process Science Data

    for ss = this.ScienceProcessing

        primaryData = ss.apply(primaryData, primaryMetaData);
        secondaryData = ss.apply(secondaryData, secondaryMetaData);
    end

    %% Assign Values

    this.Results.Primary = mag.Science(primaryData, primaryMetaData);
    this.Results.Secondary = mag.Science(secondaryData, secondaryMetaData);
end

function [mode, primaryFrequency, secondaryFrequency, packetFrequency] = extractFileMetaData(fileName)

    arguments
        fileName (1, 1) string
    end

    rawData = regexp(fileName, mag.meta.Science.MetaDataFilePattern, "names");

    if isempty(rawData)

        % Assume default values.
        if contains(fileName, "normal", IgnoreCase = true)

            mode = "Normal";
            primaryFrequency = "2";
            secondaryFrequency = "2";
            packetFrequency = "8";
        elseif contains(fileName, "burst", IgnoreCase = true)

            mode = "Burst";
            primaryFrequency = "128";
            secondaryFrequency = "128";
            packetFrequency = "2";
        else
            error("Unrecognized file name format for ""%s"".", fileName);
        end
    else

        mode = regexprep(rawData.mode, "(\w)(\w+)", "${upper($1)}$2");
        primaryFrequency = rawData.primaryFrequency;
        secondaryFrequency = rawData.secondaryFrequency;
        packetFrequency = rawData.packetFrequency;
    end
end

function period = findRampModePeriod(events)

    arguments (Input)
        events eventtable
    end

    arguments (Output)
        period (1, 1) timerange
    end

    events = events(events.Reason == "Command", :);

    idxRamp = find(contains([events.Label], "Ramp", IgnoreCase = true));
    idxRamp = vertcat(idxRamp, idxRamp + 1);

    events = events(idxRamp, :);

    if isempty(events)
        period = timerange(NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC"));
    else
        period = timerange(events.Time(1), events.Time(end), "openright");
    end
end
