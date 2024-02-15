classdef Select < mag.graphics.operation.Action
% SELECT Default action for selecting variables based on name.

    properties
        % VARIABLES Variable names to select.
        Variables (1, :) string
    end

    methods

        function this = Select(options)

            arguments
                options.?mag.graphics.operation.Select
            end

            this.assignProperties(options);
        end

        function plottableData = apply(this, originalData)

            arguments
                this (1, 1) mag.graphics.operation.Select
                originalData {mustBeA(originalData, ["mag.Data", "tabular"])}
            end

            plottableData = this.getVariables(originalData, this.Variables);
        end
    end
end
