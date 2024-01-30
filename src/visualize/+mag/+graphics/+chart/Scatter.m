classdef Scatter < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport & mag.graphics.mixin.MarkerSupport
% SCATTER Definition of chart of "scatter" type.

    methods

        function this = Scatter(options)

            arguments
                options.?mag.graphics.chart.Scatter
                options.Marker (1, 1) string = "o"
                options.MarkerSize (1, 1) double = 36
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

            xData = this.getXData(data);

            options = this.MarkerStyle;
            options(1:2:end) = cellstr(replace([options{1:2:end}], "MarkerSize", "SizeData"));

            graph = scatter(axes, xData, data{:, this.YVariables}, options{:});

            this.applyColorStyle(graph, "MarkerEdgeColor");
        end
    end
end
