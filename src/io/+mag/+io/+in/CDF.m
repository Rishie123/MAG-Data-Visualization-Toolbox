classdef (Abstract) CDF < mag.io.in.Format
% CDF Interface for CDF input format providers.

    methods (Abstract)

        % ADDTOOUTPUT Add information to output for import.
        addToOutput(this, data, rawData, cdfInfo)
    end
end
