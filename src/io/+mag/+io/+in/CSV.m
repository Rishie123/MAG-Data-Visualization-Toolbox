classdef (Abstract) CSV < mag.io.in.Format
% CSV Interface for CSV input format providers.

    properties (Constant)
        Extension = ".csv"
    end

    methods

        function [rawData, fileName] = load(~, fileName)

            dataStore = tabularTextDatastore(fileName, FileExtensions = ".csv");
            rawData = dataStore.readall(UseParallel = mag.internal.useParallel());
        end
    end
end
