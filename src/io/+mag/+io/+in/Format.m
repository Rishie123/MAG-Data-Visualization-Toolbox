classdef (Abstract) Format < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% IFORMAT Interface for data format providers for import.

    methods (Abstract)

        % LOADANDCONVERT Load data and convert to common format.
        data = loadAndConvert(this, fileName)

        % COMBINEBYTYPE Combine data by type.
        combinedData = combineByType(this, data)
    end
end
