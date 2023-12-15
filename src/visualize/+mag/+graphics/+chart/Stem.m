classdef Stem < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport & mag.graphics.mixin.MarkerSupport
% STEM Definition of chart of "stem" type.

    methods

        function this = Stem(options)

            arguments
                options.?mag.graphics.chart.Stem
                options.Marker (1, 1) string = "o"
                options.MarkerSize (1, 1) double = 6
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

            filteredData = this.filterData(data);
            xData = this.getXData(filteredData);

            graph = stem(axes, xData, filteredData{:, this.YVariables}, ...
                this.MarkerStyle{:});

            this.applyColorStyle(graph);
        end
    end
end
