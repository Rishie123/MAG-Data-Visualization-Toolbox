function loadIALiRTData(this, primarySetup, secondarySetup)
    %% Initialize

    if isempty(this.IALiRTFileNames)
        return;
    end

    this.Results.IALiRT = mag.IALiRT();

    %% Import Data

    [~, ~, extension] = fileparts(this.IALiRTPattern);
    importStrategy = this.dispatchExtension(extension, "Science");

    this.Results.IALiRT.Science = mag.io.import( ...
        FileNames = this.IALiRTFileNames, ...
        Format = importStrategy, ...
        ProcessingSteps = this.PerFileProcessing);

    primary = this.Results.IALiRT.Primary;
    primary.MetaData.Setup = primarySetup;

    secondary = this.Results.IALiRT.Secondary;
    secondary.MetaData.Setup = secondarySetup;

    %% Amend Timestamp

    startTime(1) = bounds(primary.Time);
    startTime(2) = bounds(secondary.Time);

    startTime = min(startTime);

    primary.MetaData.Timestamp = startTime;
    secondary.MetaData.Timestamp = startTime;

    %% Add Mode and Range Change Events

    emptyTime = datetime.empty();
    emptyTime.TimeZone = "UTC";

    sensorEvents = struct2table(struct(Time = emptyTime, ...
        Mode = string.empty(0, 1), ...
        PrimaryNormalRate = double.empty(0, 1), ...
        SecondaryNormalRate = double.empty(0, 1), ...
        PacketNormalFrequency = double.empty(0, 1), ...
        PrimaryBurstRate = double.empty(0, 1), ...
        SecondaryBurstRate = double.empty(0, 1), ...
        PacketBurstFrequency = double.empty(0, 1), ...
        Duration = double.empty(0, 1), ...
        Range = double.empty(0, 1), ...
        Sensor = string.empty(0, 1), ...
        Label = string.empty(0, 1), ...
        Reason = string.empty(0, 1)));
    sensorEvents = table2timetable(sensorEvents, RowTimes = "Time");

    primary.Data.Properties.Events = this.generateEventTable(primary, sensorEvents);
    secondary.Data.Properties.Events = this.generateEventTable(secondary, sensorEvents);

    %% Process Data as a Whole

    for ps = this.WholeDataProcessing

        primary.Data = ps.apply(primary.Data, primary.MetaData);
        secondary.Data = ps.apply(secondary.Data, secondary.MetaData);
    end

    %% Remove Ramp Mode (If Any)

    if ~isempty(this.PrimaryRamp) && ~isempty(this.SecondaryRamp)

        primary.Data(timerange(this.PrimaryRamp.Time(1), this.PrimaryRamp.Time(end), "closed"), :) = [];
        secondary.Data(timerange(this.SecondaryRamp.Time(1), this.SecondaryRamp.Time(end), "closed"), :) = [];
    end

    %% Process I-ALiRT Data

    for is = this.IALiRTProcessing

        primary.Data = is.apply(primary.Data, primary.MetaData);
        secondary.Data = is.apply(secondary.Data, secondary.MetaData);
    end
end
