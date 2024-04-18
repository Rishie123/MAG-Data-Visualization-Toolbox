classdef (Abstract) Format < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% IFORMAT Interface for data format providers for export.

    properties (Abstract, Constant)
        % EXTENSION Extension supported for file format.
        Extension (1, 1) string
    end

    methods (Abstract)

        % GETEXPORTFILENAME Get name of export file name.
        fileName = getExportFileName(this, data)

        % CONVERTTOEXPORTABLEFORMAT Convert data to an exportable format.
        exportData = convertToExportableFormat(this, data)

        % WRITE Export file to format.
        write(this, fileName, exportData)
    end
end
