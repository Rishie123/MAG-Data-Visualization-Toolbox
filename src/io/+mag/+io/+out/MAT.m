classdef (Abstract) MAT < mag.io.out.Format
% MAT Interface for MAT export format providers.

    methods (Abstract)

        % CONVERTTOSTRUCT Convert data to struct.
        structData = convertToStruct(this, data)
    end
end
