classdef (Abstract) CSV < mag.io.in.Format
% CSV Interface for CSV input format providers.

    methods

        function data = loadAndConvert(this, fileName)

            dataStore = tabularTextDatastore(fileName, FileExtensions = ".csv");
            rawData = dataStore.readall(UseParallel = mag.internal.useParallel());

            data = this.convert(rawData, fileName);
        end
    end

    methods (Abstract, Access = protected)

        % CONVERT Process raw data and convert to common data
        % format.
        data = convert(this, rawData, fileName)
    end
end
