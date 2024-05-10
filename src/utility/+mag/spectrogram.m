function [f, t, p] = spectrogram(x, y, options)
% SPECTROGRAM Calculate spectrogram for given signal, as a function of time
% and frequency.

    arguments (Input)
        x (:, 1) datetime
        y (:, 1) double
        options.FrequencyLimits (1, 2) double = [missing(), missing()]
        options.FrequencyPoints (1, 1) double = 256
        options.Overlap (1, 1) double {mustBeGreaterThan(options.Overlap, 0), mustBeLessThan(options.Overlap, 1)} = 0.8
        options.Normalize (1, 1) logical = true
        options.Window (1, 1) double = missing()
    end

    arguments (Output)
        f (:, 1) double
        t (:, 1) double
        p (:, :) double
    end

    % Normalize data.
    if options.Normalize

        if height(y) < 500
            y = normalize(y);
        else

            k = ceil(height(y) / 100);
            y = (y - movmean(y, k)) ./ movstd(y, k);
        end
    end

    % Compute spectrogram coefficients.
    rate = round(1 / mode(seconds(diff(x))));

    if ~ismissing(options.Window)
        w = options.Window;
    elseif rate > 100
        w = 25;
    else
        w = 5;
    end

    window = rate * w;
    overlap = round(window * options.Overlap);

    % Spectrogram.
    y(ismissing(y) | isinf(y)) = 0;

    [~, f, t, p] = spectrogram(y, window, overlap, 2 * options.FrequencyPoints, rate);

    % Filter frequencies outside bands.
    if ~any(ismissing(options.FrequencyLimits))

        locF = (f >= options.FrequencyLimits(1)) & (f <= options.FrequencyLimits(2));
        f = f(locF);
        p = p(locF, :);
    end
end