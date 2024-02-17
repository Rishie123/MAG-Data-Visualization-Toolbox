classdef Plot < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport & mag.graphics.mixin.MarkerSupport
% PLOT Definition of chart of "plot" type.

    properties
        % LINESTYLE Line style.
        LineStyle (1, 1) string = "-"
    end

    methods

        function this = Plot(options)

            arguments
                options.?mag.graphics.chart.Plot
                options.MarkerSize (1, 1) double = 6
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, ~)

            arguments (Input)
                this
                data {mustBeA(data, ["mag.Data", "tabular"])}
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            xData = this.getXData(data);
            yData = this.getYData(data);

            graph = plot(axes, xData, yData, this.MarkerStyle{:}, LineStyle = this.LineStyle);

            this.applyColorStyle(graph);
        end
    end
end
