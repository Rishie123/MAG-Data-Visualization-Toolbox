classdef Spectrogram < mag.graphics.chart.Chart
% SPECTROGRAM Definition of chart of "spectrogram" type.

    properties
        % NORMALIZE Normalize data before computing spectrum to highlight
        % spikes.
        Normalize (1, 1) logical = true
        % FREQUENCYLIMITS Specifies the frequency band limits.
        FrequencyLimits (1, 2) double = [missing(), missing()]
        % WINDOW Length of window.
        Window (1, 1) double = missing()
    end

    methods

        function this = Spectrogram(options)

            arguments
                options.?mag.graphics.chart.Spectrogram
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, ~)

            arguments (Input)
                this
                data {mustBeA(data, ["mag.Data", "timetable"])}
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            xData = this.getXData(data);
            yData = this.getYData(data);

            % Spectrogram.
            [f, t, p] = mag.computeSpectrogram(xData, yData, FrequencyLimits = this.FrequencyLimits, Normalize = this.Normalize, Window = this.Window);

            % Plot.
            graph = surf(axes, xData(1) + seconds(t), f, pow2db(abs(p)), EdgeColor = "none");

            axes.XLimitMethod = "tight";
            axes.YLimitMethod = "tight";

            view(axes, [0, 90]);
        end
    end
end
