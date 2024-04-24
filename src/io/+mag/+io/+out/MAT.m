classdef (Abstract) MAT < mag.io.out.Format
% MAT Interface for MAT export format providers.

    properties (Constant)
        Extension = ".mat"
    end

    properties
        % APPEND Append data to existing MAT file.
        Append (1, 1) logical = false
    end

    methods

        function write(this, fileName, exportData)

            arguments
                this (1, 1) mag.io.out.MAT
                fileName (1, 1) string
                exportData (1, 1) struct
            end

            if this.Append && isfile(fileName)
                extraOptions = {"-append"};
            else
                extraOptions = {};
            end

            save(fileName, "-struct", "exportData", "-mat", extraOptions{:});
        end
    end
end
