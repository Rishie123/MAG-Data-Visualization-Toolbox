classdef (Abstract) MAT < mag.io.in.Format
% MAT Interface for MAT input format providers.

    methods (Abstract)

        % CONVERTFROMSTRUCT Convert data from struct.
        data = convertFromStruct(this, structData)
    end
end
