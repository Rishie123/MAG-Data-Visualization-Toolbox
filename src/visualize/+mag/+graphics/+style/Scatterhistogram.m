classdef Scatterhistogram < mag.graphics.style.Axes
% SCATTERHISTOGRAM Style options for decoration of figure with scatter and
% histogram plot.

    properties
        % YLABEL Display name of y-axis.
        YLabel string {mustBeScalarOrEmpty} = string.empty()
        % LEGENDTITLE Display title of legend.
        LegendTitle string {mustBeScalarOrEmpty} = string.empty()
    end

    methods

        function this = Scatterhistogram(options)

            arguments
                options.?mag.graphics.style.Scatterhistogram
                options.XLimits (1, 2) double = NaN(1, 2)
                options.YLimits (1, 2) double = NaN(1, 2)
                options.Charts (1, 1) mag.graphics.chart.Scatterhistogram
            end

            this.set(options);
        end
    end

    methods (Access = protected)

        function axes = applyStyle(this, axes, graph)

            arguments (Input)
                this
                axes (1, 1) matlab.graphics.axis.Axes
                graph (1, 1) matlab.graphics.chart.ScatterHistogramChart
            end

            arguments (Output)
                axes (1, :) matlab.graphics.axis.Axes
            end

            if ~isempty(this.XLabel)
                graph.XLabel = this.XLabel;
            end

            if ~isempty(this.YLabel)
                graph.YLabel = this.YLabel;
            end

            if ~any(ismissing(this.XLimits))
                graph.XLimits = this.XLimits;
            end

            if ~any(ismissing(this.YLimits))
                graph.YLimits = this.YLimits;
            end

            if ~isempty(this.Title)
                graph.Title = this.Title;
            end

            if ~isempty(this.LegendTitle)
                graph.LegendTitle = this.LegendTitle;
            end
        end
    end
end
