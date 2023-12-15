classdef Line < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport
% LINE Definition of chart of "xline" or "yline" type.

    properties
        % AXIS Axis along which to plot.
        Axis (1, 1) string {mustBeMember(Axis, ["x", "y"])} = "y"
        % VALUE Line value.
        Value (1, 1) double
        % STYLE Line style.
        Style (1, 1) string = "-"
        % LABEL Line label.
        Label string {mustBeScalarOrEmpty}
    end

    methods

        function this = Line(options)

            arguments
                options.?mag.graphics.chart.Line
            end

            this.assignProperties(options);
        end

        function graph = plot(this, ~, axes, ~)

            arguments (Input)
                this
                ~
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            switch this.Axis
                case "x"
                    graph = xline(axes, this.Value, this.Style, this.Label);
                case "y"
                    graph = yline(axes, this.Value, this.Style, this.Label);
            end

            this.applyColorStyle(graph);
        end
    end
end
