function export(this, exportStrategy, options)

    arguments
        this (1, 1) mag.AutomatedAnalysis
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

    switch exportStrategy.Extension
        case ".mat"

            scienceExportFormat = mag.io.format.ScienceMAT();
            hkExportFormat = mag.io.format.HKMAT();
            extension = ".mat";

        case ".dat"

            scienceExportFormat = mag.io.format.ScienceDAT();
            hkExportFormat = [];
            extension = ".dat";

        otherwise
            error("Unsupported export format.");
    end

    % Export each mode.
    modes = this.getAllModes();

    for i = 1:numel(modes)

        data = {modes(i).Primary.Data(period, :), modes(i).Secondary.Data(period, :)};
        metaData = [modes(i).Primary.MetaData, modes(i).Secondary.MetaData];

        exportedData = scienceExportFormat.formatForExport(data, metaData);

        exportStrategy.ExportFileName = fullfile(options.Location, sprintf("%s %s (%d, %d)", datestr(metaData(1).Timestamp, "ddmmyy-hhMM"), metaData(1).Mode, metaData(1).DataFrequency, metaData(2).DataFrequency) + extension); %#ok<DATST>
        exportStrategy.export(exportedData);
    end

    % Export range cycling.
    rangeCycling = this.getRangeCycling();

    if ~isempty(rangeCycling)

        rangeData = scienceExportFormat.formatForExport({rangeCycling.Primary.Data, rangeCycling.Secondary.Data}, [rangeCycling.Primary.MetaData, rangeCycling.Secondary.MetaData]);

        exportStrategy.ExportFileName = fullfile(options.Location, sprintf("%s Range Cycling", datestr(rangeCycling.MetaData.Timestamp, "ddmmyy-hhMM")) + extension); %#ok<DATST>
        exportStrategy.export(rangeData);
    end

    % Export ramp mode.
    rampMode = this.getRampMode();

    if ~isempty(rampMode)

        rampData = scienceExportFormat.formatForExport({rampMode.Primary.Data, rampMode.Secondary.Data}, [rampMode.Primary.MetaData, rampMode.Secondary.MetaData]);

        exportStrategy.ExportFileName = fullfile(options.Location, sprintf("%s Ramp Mode", datestr(rampMode.MetaData.Timestamp, "ddmmyy-hhMM")) + extension); %#ok<DATST>
        exportStrategy.export(rampData);
    end

    % Export HK data.
    if ~isempty(hkExportFormat) && ~isempty(this.Results.HK)

        hkMetaData = [this.Results.HK.MetaData];

        hkData = {this.Results.HK.Data};
        hkData = cellfun(@(d) d(period, :), hkData, UniformOutput = false);

        hkData = hkExportFormat.formatForExport(hkData, hkMetaData);
    
        exportStrategy.ExportFileName = fullfile(options.Location, sprintf("%s HK", datestr(min([hkMetaData.Timestamp]), "ddmmyy-hhMM")) + extension); %#ok<DATST>
        exportStrategy.export(hkData);
    end
end
