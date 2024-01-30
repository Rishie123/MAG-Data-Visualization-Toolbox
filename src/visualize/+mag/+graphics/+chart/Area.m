classdef Area < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport
% AREA Definition of chart of "area" type.

    methods

        function this = Area(options)

            arguments
                options.?mag.graphics.chart.Area
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, ~)

            arguments (Input)
                this
                data timetable
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            xData = this.getXData(data);

            graph = area(axes, xData, data{:, this.YVariables});

            this.applyColorStyle(graph, "FaceColor");
        end
    end
end
