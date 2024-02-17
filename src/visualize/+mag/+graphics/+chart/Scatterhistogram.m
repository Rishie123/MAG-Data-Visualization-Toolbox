classdef Scatterhistogram < mag.graphics.chart.Chart
% SCATTERHISTOGRAM Definition of chart of "scatterhistogram" type.

    properties
        % GVARIABLE Variable to use to group observations.
        GVariable string {mustBeScalarOrEmpty} = string.empty()
    end

    methods

        function this = Scatterhistogram(options)

            arguments
                options.?mag.graphics.chart.Scatterhistogram
                options.YVariables (1, 1) {mustBeA(options.YVariables, ["string", "mag.graphics.operations.Select"])}
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, ~, layout)

            arguments (Input)
                this
                data {mustBeA(data, ["mag.Data", "tabular"])}
                ~
                layout (1, 1) matlab.graphics.layout.TiledChartLayout
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            xData = this.getXData(data);
            yData = this.getYData(data);

            if isempty(this.GVariable)
                options = {};
            else
                options = {"GroupData", data{:, this.GVariable}, "LegendVisible", "on"};
            end

            graph = scatterhistogram(layout, xData, yData, options{:});
        end
    end
end
