classdef Histogram < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport
% HISTOGRAM Definition of chart of "histogram" type.

    methods

        function this = Histogram(options)

            arguments
                options.?mag.graphics.chart.Histogram
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, ~)

            arguments (Input)
                this
                data {mustBeA(data, ["mag.Data", "table"])}
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            yData = this.getYData(data);

            graph = histogram(axes, yData);

            this.applyColorStyle(graph, "FaceColor");
        end
    end
end
