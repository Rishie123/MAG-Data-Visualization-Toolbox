classdef (Abstract) CDF < mag.io.in.Format
% CDF Interface for CDF input format providers.

    methods

        function [rawData, cdfInfo] = load(~, fileName)

            cdfInfo = spdfcdfinfo(fileName);
            rawData = spdfcdfread(fileName, 'CDFEpochtoString', true);
        end
    end
end
