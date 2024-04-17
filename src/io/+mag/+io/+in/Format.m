classdef (Abstract) Format < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% IFORMAT Interface for data format providers for import.

    methods (Abstract)

        % LOAD Load raw data from file.
        rawData = load(this, fileName)
    
        % PROCESS Process raw data and convert to common data
        % format.
        data = process(this, rawData, varargin)
    end
end
