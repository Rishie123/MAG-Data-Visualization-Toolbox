classdef (Abstract) Type < mag.mixin.SetGet
% TYPE Import/Export type for MAG science and HK data.

    properties (Abstract, Constant)
        % EXTENSION Extension supported for file format.
        Extension (1, 1) string
    end

    properties (Abstract, Constant, Access = protected)
        % SCIENCEFORMAT Science import/export format.
        ScienceFormat (1, 1) mag.io.format.Data
        % HKFORMAT Housekeeping import/export format.
        HKFormat (1, 1) mag.io.format.Data
    end

    properties
        % IMPORTFILENAMES One or more files to import.
        ImportFileNames (1, :) string {mustBeFile}
        % EXPORTFILENAME File to export to.
        ExportFileName (1, 1) string
    end

    methods (Abstract)

        % IMPORT Import data from one or more files.
        data = import(this, options)

        % EXPORT Export data to a file.
        export(this, data, options)
    end

    methods (Access = protected)

        function data = processFromImport(this, importData)
        % PROCESSFROMIMPORT Process imported data to produce science or
        % housekeeping data.

            if isa(importData, "mag.Science")
                formatter = this.ScienceFormat;
            elseif isa(importData, "mag.HK")
                formatter = this.HKFormat;
            else
                error("Invalid type ""%s"" for export.", class(importData));
            end

            assert(~isempty(formatter), "Undefined formatter for type ""%s"".", class(importData));
            data = formatter.formatFromImport(importData);
        end

        function exportData = processForExport(this, data)
        % PROCESSFOREXPORT Process science or housekeeping data to produce
        % exportable data.

            if isa(data, "mag.Science")
                formatter = this.ScienceFormat;
            elseif isa(data, "mag.HK")
                formatter = this.HKFormat;
            else
                error("Invalid type ""%s"" for export.", class(data));
            end

            assert(~isempty(formatter), "Undefined formatter for type ""%s"".", class(data));
            exportData = formatter.formatForExport(data);
        end
    end
end
