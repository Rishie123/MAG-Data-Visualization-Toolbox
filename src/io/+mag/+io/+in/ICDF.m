classdef (Abstract) ICDF < mag.io.in.IFormat
% ICDF Interface for CDF input format providers.

    methods (Abstract)

        % ADDTOOUTPUT Add information to output for import.
        addToOutput(this, data, rawData)
    end
end
