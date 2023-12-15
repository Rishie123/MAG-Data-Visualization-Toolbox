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

            filteredData = this.filterData(data);

            hold(axes, "on");
            resetAxesHold = onCleanup(@() hold(axes, "off"));

            if iscell(filteredData)

                for i = 1:numel(this.YVariables)
                    graph(i) = area(axes, filteredData{i}.(xVariable), filteredData{i}{:, this.YVariables(i)}); %#ok<AGROW>
                end
            else
                graph = area(axes, filteredData.(xVariable), filteredData{:, this.YVariables});
            end

            this.applyColorStyle(graph, "FaceColor");
        end
    end
end
