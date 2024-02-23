classdef MAT < mag.io.Type
% MAT Import/Export MAG data to/from MAT.

    properties (Constant)
        Extension = ".mat"
    end

    properties (Dependent)
        ScienceExportFormat
        HKExportFormat
    end

    properties
        % APPEND Append data to existing MAT file.
        Append (1, 1) logical = false
    end

    methods

        function this = MAT(options)

            arguments
                options.?mag.io.MAT
            end

            args = namedargs2cell(options);

            if ~isempty(args)
                this.set(args{:});
            end
        end

        function scienceExportFormat = get.ScienceExportFormat(~)
            scienceExportFormat = mag.io.format.ScienceMAT();
        end

        function hkExportFormat = get.HKExportFormat(~)
            hkExportFormat = mag.io.format.HKMAT();
        end
    end

    methods

        function data = import(this, ~)

            arguments (Input)
                this
                ~
            end

            arguments (Output)
                data (1, :) struct
            end

            for i = 1:numel(this.ImportFileNames)

                matData = load(this.ImportFileNames(i), "data", "-mat");
                assert(~isempty(matData), "MAT file using unsupported format.");

                data(i) = matData.data; %#ok<AGROW>
            end
        end

        function export(this, data, ~)

            arguments
                this
                data (1, 1) struct
                ~
            end

            if this.Append
                extraOptions = {"-append"};
            else
                extraOptions = {};
            end

            save(this.ExportFileName, "-struct", "data", "-mat", extraOptions{:});
        end
    end
end
