classdef CSV < mag.io.Type
% CSV Import/Export MAG data to/from CSV.

    properties (Constant)
        Extension = ".csv"
    end

    methods

        function this = CSV(options)

            arguments
                options.?mag.io.CSV
            end

            this.assignProperties(options);
        end
    end

    methods

        function import(this, options, importOptions)

            arguments (Input)
                this (1, 1) mag.io.CSV
                options.FileNames (1, :) string {mustBeFile}
                importOptions.?mag.io.in.Settings
                importOptions.Format (1, 1) mag.io.in.CSV
            end

            importArgs = namedargs2cell(importOptions);
            importSettings = mag.io.in.Settings(importArgs{:});

            format = importSettings.Format;

            for fn = options.FileNames

                % Check there is at least one line of data in the file.
                if nnz(~cellfun(@isempty, strsplit(fileread(fn), newline()))) < 2
                    continue;
                end

                % Import data.
                dataStore = tabularTextDatastore(fn, FileExtensions = this.Extension);
                rawData = dataStore.readall(UseParallel = mag.internal.useParallel());

                partialData = format.convert(rawData, fn);
                format.applyProcessingSteps(partialData, importSettings.PerFileProcessing);

                format.assignToOutput(importSettings.Output, partialData);
            end

            format.applyProcessingSteps(partialData, importSettings.WholeDataProcessing);
        end

        function export(this, data, options) %#ok<INUSD>
            error("Unsupported export to CSV.");
        end
    end
end
