classdef Scatterhistogram < mag.graphics.chart.Chart
% SCATTERHISTOGRAM Definition of chart of "scatterhistogram" type.

    properties
        % GROUPVARIABLE Variable to use to group observations.
        GroupVariable string {mustBeScalarOrEmpty} = string.empty()
    end

    methods

        function this = Scatterhistogram(options)

            arguments
                options.?mag.graphics.chart.Scatterhistogram
                options.YVariables (1, 1) string
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, ~, layout)

            arguments (Input)
                this
                data table
                ~
                layout (1, 1) matlab.graphics.layout.TiledChartLayout
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            filteredData = this.filterData(data);
            assert(~iscell(filteredData), "Different filter lengths not currently supported.");

            if isempty(this.GroupVariable)
                options = {};
            else

                options = {"GroupVariable", this.GroupVariable, ...
                    "LegendVisible", "on"};
            end

            graph = scatterhistogram(layout, filteredData, this.XVariable, this.YVariables, options{:});
        end
    end
end
