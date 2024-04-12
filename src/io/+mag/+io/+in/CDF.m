classdef (Abstract) CDF < mag.io.in.Format
% CDF Interface for CDF input format providers.

    methods (Abstract)

        % CONVERT Process raw data and convert to common data
        % format.
        data = convert(this, rawData, cdfInfo)
    end
end
