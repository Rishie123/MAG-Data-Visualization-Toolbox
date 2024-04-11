classdef (Abstract) IMAT < mag.io.in.IFormat
% IMAT Interface for MAT input format providers.

    methods (Abstract)

        % CONVERTFROMSTRUCT Convert data from struct.
        data = convertFromStruct(this, structData)
    end
end
