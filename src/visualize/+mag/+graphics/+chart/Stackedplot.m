classdef Stackedplot < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport
% STACKEDPLOT Definition of chart of "stackedplot" type.

    properties
        % MARKER Marker symbol.
        Marker (1, 1) string = "none"
    end

    methods

        function this = Stackedplot(options)

            arguments
                options.?mag.graphics.chart.Stackedplot
                options.Colors (:, 3) double = colororder()
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, layout)

            arguments (Input)
                this
                data timetable
                axes (1, 1) matlab.graphics.axis.Axes
                layout (1, 1) matlab.graphics.layout.TiledChartLayout
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            Ny = numel(this.YVariables);

            % Filter data.
            filteredData = this.filterData(data);
            assert(~iscell(filteredData), "Different filter lengths not currently supported.");

            xData = this.getXData(filteredData);

            if ~isempty(this.Colors) && (Ny > size(this.Colors, 1))
                error("Mismatch in number of colors for number of plots.");
            end

            % Create custom stacked plot.
            graph = matlab.graphics.chart.primitive.Line.empty(0, Ny);
            stackLayout = tiledlayout(layout, Ny, 1, TileSpacing = "tight", Padding = "tight", Layout = axes.Layout);

            for y = 1:Ny

                ax = nexttile(stackLayout);
                graph(y) = plot(ax, xData, filteredData.(this.YVariables(y)), Marker = this.Marker, Color = this.Colors(y, :));
            end
        end
    end
end
