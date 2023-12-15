classdef Spectrogram < mag.graphics.chart.Chart
% SPECTROGRAM Definition of chart of "spectrogram" type.

    properties
        % NORMALIZE Normalize data before computing spectrum to highlight
        % spikes.
        Normalize (1, 1) logical = true
        % FREQUENCYLIMITS Specifies the frequency band limits.
        FrequencyLimits (1, 2) double = NaN(1, 2)
        % WINDOW Length of window.
        Window (1, 1) double = NaN()
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
                data timetable
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            xData = this.getXData(data);

            % Normalize data.
            if this.Normalize

                yData = data.(this.YVariables);

                if numel(yData) < 500
                    yData = (yData - mean(yData)) ./ std(yData);
                else

                    k = ceil(numel(yData) / 100);
                    yData = (yData - movmean(yData, k)) ./ movstd(yData, k);
                end
            else
                yData = data.(this.YVariables);
            end

            % Compute spectrogram coefficients.
            rate = round(1 / mode(seconds(diff(xData))));
            o = 0.8;

            if ~ismissing(this.Window)
                w = this.Window;
            elseif rate > 100
                w = 25;
            else
                w = 5;
            end

            % Spectrogram.
            yData(ismissing(yData) | isinf(yData)) = 0;

            [~, f, t, p] = spectrogram(yData, rate * w, rate * w * o, 512, rate);

            % Filter frequencies outside bands.
            if ~any(ismissing(this.FrequencyLimits))

                locF = (f >= this.FrequencyLimits(1)) & (f <= this.FrequencyLimits(2));
                f = f(locF);
                p = p(locF, :);
            end

            % Plot.
            graph = surf(axes, xData(1) + seconds(t), f, pow2db(abs(p)), EdgeColor = "none");

            axes.XLimitMethod = "tight";
            axes.YLimitMethod = "tight";

            view(axes, [0, 90]);
        end
    end
end
