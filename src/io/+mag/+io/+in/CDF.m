classdef (Abstract) CDF < mag.io.in.Format
% CDF Interface for CDF input format providers.

    properties (Constant)
        Extension = ".cdf"
    end

    methods

        function [rawData, cdfInfo] = load(~, fileName)

            assert(exist("spdfcdfinfo", "file"), "SPDF CDF Toolbox needs to be installed.");

            cdfInfo = spdfcdfinfo(fileName);
            rawData = spdfcdfread(fileName, 'KeepEpochAsIs', true);
        end
    end
end
