classdef Stem < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport & mag.graphics.mixin.MarkerSupport
% STEM Definition of chart of "stem" type.

    properties
        % LINESTYLE Line style.
        LineStyle (1, 1) string = "-"
    end

    methods

        function this = Stem(options)

            arguments
                options.?mag.graphics.chart.Stem
                options.Marker (1, 1) string = "o"
                options.MarkerSize (1, 1) double = 6
                options.MarkerColor {mag.graphics.mixin.mustBeColor} = []
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

            graph = stem(axes, xData, yData, this.MarkerStyle{:}, ...
                LineStyle = this.LineStyle);

            this.applyColorStyle(graph);
        end
    end
end
