classdef (Abstract) CSV < mag.io.in.Format
% CSV Interface for CSV input format providers.

    methods

        function [rawData, fileName] = load(~, fileName)

            dataStore = tabularTextDatastore(fileName, FileExtensions = ".csv");
            rawData = dataStore.readall(UseParallel = mag.internal.useParallel());
        end
    end
end
