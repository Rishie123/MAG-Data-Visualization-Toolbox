classdef Stairs < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport & mag.graphics.mixin.MarkerSupport
% STAIRS Definition of chart of "stairs" type.

    properties
        % LINESTYLE Line style.
        LineStyle (1, 1) string = "-"
    end

    methods

        function this = Stairs(options)

            arguments
                options.?mag.graphics.chart.Stairs
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, ~)

            arguments (Input)
                this
                data tabular
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            options = [{"LineStyle", this.LineStyle}, this.MarkerStyle(:)'];

            if isempty(this.XVariable)
                graph = stairs(axes, data, this.YVariables, options{:});
            else
                graph = stairs(axes, data{:, this.XVariable}, data{:, this.YVariables}, options{:});
            end

            this.applyColorStyle(graph);
        end
    end
end
