classdef (Abstract) CSV < mag.io.in.Format
% CSV Interface for CSV input format providers.

    methods (Abstract)

        % CONVERT Process raw data and convert to common data
        % format.
        data = convert(this, rawData, fileName)
    end
end
