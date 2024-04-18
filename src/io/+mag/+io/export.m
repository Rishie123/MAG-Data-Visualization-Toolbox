function export(data, options)
% EXPORT Export data to specified files with specified format.

    arguments
        data (1, :) mag.TimeSeries
        options.Location (1, 1) string {mustBeFolder}
        options.FileName string {mustBeScalarOrEmpty}
        options.Format (1, 1) mag.io.out.Format
    end

    if isempty(options.FileName)
        fileName = fullfile(options.Location, options.Format.getExportFileName(data));
    else
        fileName = fullfile(options.Location, options.FileName);
    end

    exportData = options.Format.convertToExportableFormat(data);
    options.Format.write(fileName, exportData);
end
