classdef (Abstract) IFormat < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% IFORMAT Interface for data format providers for import.

    methods (Abstract)

        % INITIALIZEOUTPUT Initialize output for import.
        data = initializeOutput(this)
    end
end
