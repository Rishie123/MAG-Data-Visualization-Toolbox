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

        function import(~, options, importOptions)

            arguments (Input)
                ~
                options.FileNames (1, :) string {mustBeFile}
                importOptions.?mag.io.in.Settings
                importOptions.Format (1, 1) mag.io.in.CDF
            end

            importArgs = namedargs2cell(importOptions);
            importSettings = mag.io.in.Settings(importArgs{:});

            format = importSettings.Format;

            for fn = options.FileNames

                cdfInfo = spdfcdfinfo(fn);
                rawData = spdfcdfread(fn, 'CDFEpochtoString', true);

                partialData = format.convert(rawData, cdfInfo);
                format.applyProcessingSteps(partialData, importSettings.PerFileProcessing);

                format.assignToOutput(importSettings.Output, partialData);
            end

            format.applyProcessingSteps(partialData, importSettings.WholeDataProcessing);
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
