function export(this, exportStrategy, options)

    arguments
        this (1, 1) mag.IMAPAnalysis
        exportStrategy (1, 1) mag.io.Type
        options.Location (1, 1) string {mustBeFolder} = "results"
        options.StartTime (1, 1) datetime = NaT(TimeZone = "UTC")
        options.EndTime (1, 1) datetime = NaT(TimeZone = "UTC")
    end

    if ismissing(options.StartTime)
        options.StartTime = datetime("-Inf", TimeZone = "UTC");
    end

    if ismissing(options.EndTime)
        options.EndTime = datetime("Inf", TimeZone = "UTC");
    end

    period = timerange(options.StartTime, options.EndTime, "closed");
    extension = exportStrategy.Extension;

    % Export full science.
    if this.Results.HasScience

        results = this.Results.copy();
        results.crop(period);

        exportStrategy.export(results, Location = options.Location);
    end

    % Export each mode.
    modes = this.getAllModes();

    for m = modes

        m.crop(period);
        exportStrategy.export(m, Location = options.Location);
    end

    % Export I-ALiRT.
    iALiRT = this.Results.IALiRT;

    if ~isempty(iALiRT)

        iALiRT.crop(period);
        exportStrategy.export(iALiRT, Location = options.Location);
    end

    % Export range cycling.
    rangeCycling = this.getRangeCycling();

    if ~isempty(rangeCycling)
        exportStrategy.export(rangeCycling, Location = options.Location, FileName = compose("%s Range Cycling", datestr(rangeCycling.MetaData.Timestamp, "ddmmyy-hhMM")) + extension); %#ok<DATST>
    end

    % Export ramp mode.
    rampMode = this.getRampMode();

    if ~isempty(rampMode)
        exportStrategy.export(rampMode, Location = options.Location, FileName = compose("%s Ramp Mode", datestr(rampMode.MetaData.Timestamp, "ddmmyy-hhMM")) + extension); %#ok<DATST>
    end

    % Export HK data.
    if ~isempty(this.Results.HK)

        hk = this.Results.HK.copy();
        hk.crop(period);

        exportStrategy.export(hk, Location = options.Location);
    end
end
