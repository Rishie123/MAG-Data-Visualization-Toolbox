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
    scienceExportFormat = exportStrategy.ScienceExportFormat;
    hkExportFormat = exportStrategy.HKExportFormat;

    % Export full science.
    if this.Results.HasScience

        r = this.Results.copy();
        r.crop(period);

        scienceData = scienceExportFormat.formatForExport(r);

        exportStrategy.ExportFileName = fullfile(options.Location, compose("%s %s (%d, %d)", datestr(r.Primary.MetaData.Timestamp, "ddmmyy-hhMM"), r.Primary.MetaData.Mode, r.Primary.MetaData.DataFrequency, r.Secondary.MetaData.DataFrequency) + extension); %#ok<DATST>
        exportStrategy.export(scienceData);
    end

    % Export each mode.
    modes = this.getAllModes();

    for m = modes

        m.crop(period);
        modeData = scienceExportFormat.formatForExport(m);

        exportStrategy.ExportFileName = fullfile(options.Location, compose("%s %s (%d, %d)", datestr(m.Primary.MetaData.Timestamp, "ddmmyy-hhMM"), m.Primary.MetaData.Mode, m.Primary.MetaData.DataFrequency, m.Secondary.MetaData.DataFrequency) + extension); %#ok<DATST>
        exportStrategy.export(modeData);
    end

    % Export I-ALiRT.
    iALiRT = this.Results.IALiRT;

    if ~isempty(iALiRT)

        iALiRT.crop(period);
        iALiRTData = scienceExportFormat.formatForExport(iALiRT);

        exportStrategy.ExportFileName = fullfile(options.Location, compose("%s %s (%.2f, %.2f)", datestr(iALiRT.Primary.MetaData.Timestamp, "ddmmyy-hhMM"), iALiRT.Primary.MetaData.Mode, iALiRT.Primary.MetaData.DataFrequency, iALiRT.Secondary.MetaData.DataFrequency) + extension); %#ok<DATST>
        exportStrategy.export(iALiRTData);
    end

    % Export range cycling.
    rangeCycling = this.getRangeCycling();

    if ~isempty(rangeCycling)

        rangeData = scienceExportFormat.formatForExport(rangeCycling);

        exportStrategy.ExportFileName = fullfile(options.Location, compose("%s Range Cycling", datestr(rangeCycling.MetaData.Timestamp, "ddmmyy-hhMM")) + extension); %#ok<DATST>
        exportStrategy.export(rangeData);
    end

    % Export ramp mode.
    rampMode = this.getRampMode();

    if ~isempty(rampMode)

        rampData = scienceExportFormat.formatForExport(rampMode);

        exportStrategy.ExportFileName = fullfile(options.Location, compose("%s Ramp Mode", datestr(rampMode.MetaData.Timestamp, "ddmmyy-hhMM")) + extension); %#ok<DATST>
        exportStrategy.export(rampData);
    end

    % Export HK data.
    if ~isempty(hkExportFormat) && ~isempty(this.Results.HK)

        hk = this.Results.HK.copy();
        hk.crop(period);

        hkData = hkExportFormat.formatForExport(hk);
        hkMetaData = [hk.MetaData];
    
        exportStrategy.ExportFileName = fullfile(options.Location, compose("%s HK", datestr(min([hkMetaData.Timestamp]), "ddmmyy-hhMM")) + extension); %#ok<DATST>
        exportStrategy.export(hkData);
    end
end
