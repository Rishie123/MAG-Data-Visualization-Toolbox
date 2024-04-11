classdef MAT < mag.io.Type
% MAT Import/Export MAG data to/from MAT.

    properties (Constant)
        Extension = ".mat"
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

            this.assignProperties(options);
        end
    end

    methods

        function data = import(this, options)

            arguments (Input)
                this (1, 1) mag.io.MAT
                options.Type (1, 1) string {mustBeMember(options.Type, ["Science", "I-ALiRT", "HK"])}
            end

            arguments (Output)
                data (1, :) mag.Instrument
            end

            format = this.getImportFormat(options.Type);

            for i = 1:numel(this.ImportFileNames)

                matData = load(this.ImportFileNames(i), "data", "-mat");
                assert(~isempty(matData), "MAT file using unsupported format.");

                data(i) = format.convertFromStruct(matData.data); %#ok<AGROW>
            end
        end

        function export(this, data, options)

            arguments
                this (1, 1) mag.io.MAT
                data (1, 1) {mustBeA(data, ["mag.Instrument", "mag.IALiRT", "mag.HK"])}
                options.Location (1, 1) string {mustBeFolder}
                options.FileName string {mustBeScalarOrEmpty}
            end

            format = this.getExportFormat(data);
            structData = format.convertToStruct(data);

            if this.Append
                extraOptions = {"-append"};
            else
                extraOptions = {};
            end

            save(format.getExportFileName(options.FileName, data), "-struct", "structData", "-mat", extraOptions{:});
        end
    end
end
