classdef Convert < mag.graphics.operation.Action
% CONVERT Convert input with specified function.

    properties
        % CONVERSION Conversion variable to use.
        Conversion (1, 1) function_handle = @sqrt
        % ARGUMENTS Other arguments for conversion function.
        Arguments (1, :) cell = cell.empty()
    end

    methods

        function this = Convert(options)

            arguments
                options.?mag.graphics.operation.Convert
            end

            this.assignProperties(options);
        end

        function plottableData = apply(this, originalData)

            arguments
                this (1, 1) mag.graphics.operation.Convert
                originalData
            end

            plottableData = this.Conversion(originalData, this.Arguments{:});
        end
    end
end
