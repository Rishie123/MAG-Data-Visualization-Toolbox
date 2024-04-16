classdef (Abstract) CDF < mag.io.in.Format
% CDF Interface for CDF input format providers.

    methods

        function data = loadAndConvert(this, fileName)

            cdfInfo = spdfcdfinfo(fileName);
            rawData = spdfcdfread(fileName, 'CDFEpochtoString', true);

            data = this.convert(rawData, cdfInfo);
        end
    end

    methods (Abstract, Access = protected)

        % CONVERT Process raw data and convert to common data
        % format.
        data = convert(this, rawData, cdfInfo)
    end
end
