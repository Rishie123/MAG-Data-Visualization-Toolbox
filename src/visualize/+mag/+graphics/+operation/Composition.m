classdef Composition < mag.graphics.operation.Action
% COMPOSITION Composition of operations to be applied sequentially.

    properties
        % OPERATIONS Operations to apply in order.
        Operations (1, :) mag.graphics.operation.Action
    end

    methods

        function this = Composition(options)

            arguments
                options.?mag.graphics.operation.Composition
            end

            this.assignProperties(options);
        end

        function plottableData = apply(this, originalData)

            arguments
                this (1, 1) mag.graphics.operation.Composition
                originalData {mustBeA(originalData, ["mag.Data", "tabular"])}
            end

            plottableData = originalData;

            for o = this.Operations
                plottableData = o.apply(plottableData);
            end
        end
    end
end
