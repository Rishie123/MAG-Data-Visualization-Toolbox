classdef CSV < mag.io.Type
% CSV Import/Export MAG data to/from CSV.

    properties (Constant)
        Extension = ".csv"
    end

    properties (Dependent)
        ScienceExportFormat
        HKExportFormat
    end

    methods

        function this = CSV(options)

            arguments
                options.?mag.io.CSV
            end

            this.assignProperties(options);
        end

        function scienceExportFormat = get.ScienceExportFormat(~)
            scienceExportFormat = [];
        end

        function hkExportFormat = get.HKExportFormat(~)
            hkExportFormat = [];
        end
    end

    methods

        function data = import(this, ~)

            % Import data as tables.
            data = cell.empty();

            for i = 1:numel(this.ImportFileNames)

                % Check there is at least one line of data in the file.
                if nnz(~cellfun(@isempty, strsplit(fileread(this.ImportFileNames(i)), newline))) < 2
                    continue;
                end

                dataStore = tabularTextDatastore(this.ImportFileNames(i), FileExtensions = this.Extension);
                data{i} = dataStore.readall(UseParallel = mag.internal.useParallel());
            end
        end

        function export(this, data, options) %#ok<INUSD>
            error("Unsupported export to CSV.");
        end
    end
end
