classdef Default < mag.graphics.style.Axes & mag.graphics.mixin.GridSupport & mag.graphics.mixin.LegendSupport
% DEFAULT Style options for decoration of figure with a single y-axis
% variable to plot.

    properties
        % YLABEL Display name of y-axis.
        YLabel (1, 1) string
        % XSCALE Scale of x-axis.
        XScale (1, 1) string {mustBeMember(XScale, ["linear", "log"])} = "linear"
        % YSCALE Scale of y-axis.
        YScale (1, 1) string {mustBeMember(YScale, ["linear", "log"])} = "linear"
    end

    methods

        function this = Default(options)

            arguments
                options.?mag.graphics.style.Default
            end

            this.set(options);
        end
    end

    methods (Access = protected)

        function axes = applyStyle(this, axes, ~)

            arguments (Input)
                this
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                axes (1, :) matlab.graphics.axis.Axes
            end

            xlabel(axes, this.XLabel);
            xlim(axes, this.XLimits);

            ylabel(axes, this.YLabel);
            ylim(axes, this.YLimits);

            xscale(axes, this.XScale);
            yscale(axes, this.YScale);

            if ~isempty(this.Title)
                title(axes, this.Title);
            end

            this.applyGridStyle(axes);
            this.applyLegendStyle(axes);
        end
    end
end
