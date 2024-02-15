classdef Difference < mag.graphics.operation.Action
% DIFFERENCE Perform difference of two variables.

    properties
        % MINUEND Name of property to subtract from.
        Minuend (1, 1) string
        % SUBTRAHEND Name of property to be subtracted.
        Subtrahend (1, 1) string
    end

    methods

        function this = Difference(options)

            arguments
                options.?mag.graphics.operation.Difference
            end

            this.assignProperties(options);
        end

        function plottableData = apply(this, originalData)

            arguments
                this (1, 1) mag.graphics.operation.Difference
                originalData {mustBeA(originalData, ["mag.Data", "tabular"])}
            end

            minuend = this.getVariables(originalData, this.Minuend);
            subtrahend = this.getVariables(originalData, this.Subtrahend);

            plottableData = minuend - subtrahend;
        end
    end
end
