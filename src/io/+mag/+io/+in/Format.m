classdef (Abstract) Format < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% IFORMAT Interface for data format providers for import.

    methods (Abstract)

        % APPLYPROCESSINGSTEPS Process data according to input steps.
        applyProcessingSteps(this, data, processingStep)

        % ASSIGNTOOUTPUT Assign partial result to output data.
        assignToOutput(this, output, partialData)
    end
end
