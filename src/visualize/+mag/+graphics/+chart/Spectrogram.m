classdef Spectrogram < mag.graphics.chart.Chart
% SPECTROGRAM Definition of chart of "spectrogram" type.

    properties
        % NORMALIZE Normalize data before computing spectrum to highlight
        % spikes.
        Normalize (1, 1) logical = true
        % FREQUENCYLIMITS Specifies the frequency band limits.
        FrequencyLimits (1, 2) double = [missing(), missing()]
        % FREQUENCYPOINTS Number of frequency samples.
        FrequencyPoints (1, 1) double = 256
        % WINDOW Length of window.
        Window (1, 1) double = missing()
        % OVERLAP Number of overlapped samples.
        Overlap (1, 1) double = missing()
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
                this (1, 1) mag.graphics.chart.Spectrogram
                data {mustBeA(data, ["mag.Data", "timetable"])}
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            xData = this.getXData(data);
            yData = this.getYData(data);

            % Scale overlap parameter based on number of elements.
            N = numel(xData);

            if ~ismissing(this.Overlap)
                overlap = this.Overlap;
            elseif N < 1e4
                overlap = 0.8;
            elseif N > 1e6
                overlap = 0.3;
            else
                overlap = 0.8 + (N * (0.8 - 0.3) / (1e4 - 1e6));
            end

            % Spectrogram.
            [f, t, p] = mag.spectrogram(xData, yData, FrequencyLimits = this.FrequencyLimits, FrequencyPoints = this.FrequencyPoints, ...
                Normalize = this.Normalize, Window = this.Window, Overlap = overlap);

            % Plot.
            graph = surf(axes, t, f, pow2db(abs(p)), EdgeColor = "none");

            axes.XLimitMethod = "tight";
            axes.YLimitMethod = "tight";

            view(axes, [0, 90]);
        end
    end
end
