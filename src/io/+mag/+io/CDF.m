classdef CDF < mag.io.Type
% CDF Import/Export MAG data to/from CDF.

    properties (Constant)
        Extension = ".cdf"
    end

    methods

        function this = CDF(options)

            arguments
                options.?mag.io.CDF
            end

            assert(exist("spdfcdfinfo", "file"), "SPDF CDF library should be installed.");
            this.assignProperties(options);
        end
    end

    methods

        function data = import(this, options)

            arguments (Input)
                this (1, 1) mag.io.CDF
                options.Type (1, 1) string {mustBeMember(options.Type, ["Science", "I-ALiRT", "HK"])}
                options.FileNames (1, :) string {mustBeFile}
            end

            arguments (Output)
                data (1, 1) mag.Instrument
            end

            format = this.getImportFormat(options.Type);
            data = format.initializeOutput();

            for fn = options.FileNames

                cdfInfo = spdfcdfinfo(fn);
                rawData = spdfcdfread(fn);

                format.addToOutput(data, cdfInfo, rawData);
            end
        end

        function export(this, data, options)

            arguments
                this (1, 1) mag.io.CDF
                data (1, 1) {mustBeA(data, ["mag.Instrument", "mag.IALiRT", "mag.HK"])}
                options.Location (1, 1) string {mustBeFolder}
            end

            this.doExport(data.Primary, options.Location);
            this.doExport(data.Secondary, options.Location);
        end
    end

    methods (Access = private)

        function doExport(this, data, location)

            format = this.getExportFormat(data);
            cdfInfo = spdfcdfinfo(format.getSkeletonFileName(data));

            spdfcdfwrite(char(fullfile(location, format.getExportFileName(string.empty(), data))), ...
                format.getVariableList(cdfInfo, data), ...
                'GlobalAttributes', format.getGlobalAttributes(cdfInfo), ...
                'VariableAttributes', format.getVariableAttributes(cdfInfo, data), ...
                'ConvertDatenumToTT2000', true, ...
                'WriteMode', 'overwrite', ...
                'Format', 'singlefile', ...
                'RecordBound', format.getRecordBound(cdfInfo), ...
                'CDFCompress', 'gzip.6',...
                'Checksum', 'MD5', ...
                'VarDatatypes', format.getVariableDataType(cdfInfo));
        end
    end
end
