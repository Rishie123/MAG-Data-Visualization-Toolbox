classdef (Abstract) IMAT < mag.io.out.IFormat
% IMAT Interface for MAT export format providers.

    methods (Abstract)

        % CONVERTTOSTRUCT Convert data to struct.
        structData = convertToStruct(this, data)
    end
end
