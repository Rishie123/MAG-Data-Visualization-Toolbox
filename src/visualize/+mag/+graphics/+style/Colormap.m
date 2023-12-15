classdef Colormap < mag.graphics.style.Default
% COLORMAP Style options for decoration of figure with a y-axis variable to
% plot and color information.

    properties
        % CLABEL Display name of color map.
        CLabel (1, 1) string
        % MAP Color look-up table.
        Map (1, 1) string = "jet"
    end

    methods

        function this = Colormap(options)

            arguments
                options.?mag.graphics.style.Colormap
                options.Charts (1, 1) mag.graphics.chart.Spectrogram
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

            applyStyle@mag.graphics.style.Default(this, axes);

            % Add colorbar.
            c = colorbar(axes);
            c.Label.String = this.CLabel;

            % Set colormap.
            colormap(axes, this.Map);
        end
    end
end
