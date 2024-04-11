classdef (Abstract) Type < mag.mixin.SetGet
% TYPE Import/Export type for MAG science and HK data.

    properties (Abstract, Constant)
        % EXTENSION Extension supported for file format.
        Extension (1, 1) string
    end

    properties
        % SCIENCEIMPORTFORMAT Science import format.
        ScienceImportFormat mag.io.in.IFormat {mustBeScalarOrEmpty}
        % SCIENCEEXPORTFORMAT Science export format.
        ScienceExportFormat mag.io.out.IFormat {mustBeScalarOrEmpty}
        % HKIMPORTFORMAT Housekeeping import format.
        HKImportFormat mag.io.in.IFormat {mustBeScalarOrEmpty}
        % HKEXPORTFORMAT Housekeeping export format.
        HKExportFormat mag.io.out.IFormat {mustBeScalarOrEmpty}
    end

    methods (Abstract)

        % IMPORT Import data from one or more files.
        data = import(this, options)

        % EXPORT Export data to a file.
        export(this, data, options)
    end

    methods (Access = protected)

        function format = getImportFormat(this, type)
        % GETIMPORTFORMAT Retrieve format based on import type.

            arguments (Output)
                format (1, 1) mag.io.in.IFormat
            end

            switch type
                case {"Science", "I-ALiRT"}
                    format = this.ScienceImportFormat;
                case "HK"
                    format = this.HKImportFormat;
                otherwise
                    error("Invalid type ""%s"" for import.", type);
            end
        end

        function format = getExportFormat(this, data)
        % GETEXPORTFORMAT Retrieve format based on export data type.

            arguments (Output)
                format (1, 1) mag.io.out.IFormat
            end

            if isa(data, "mag.Science")
                format = this.ScienceExportFormat;
            elseif isa(data, "mag.HK")
                format = this.HKExportFormat;
            else
                error("Invalid type ""%s"" for export.", class(data));
            end
        end
    end
end
