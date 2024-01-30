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

            if isempty(this.XVariable)
                xVariable = data.Properties.DimensionNames{1};
            else
                xVariable = this.XVariable;
            end

            hold(axes, "on");
            resetAxesHold = onCleanup(@() hold(axes, "off"));

            graph = area(axes, data.(xVariable), data{:, this.YVariables});

            this.applyColorStyle(graph, "FaceColor");
        end
    end
end
