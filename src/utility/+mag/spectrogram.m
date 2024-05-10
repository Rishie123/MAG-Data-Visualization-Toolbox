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
        t (:, 1) datetime
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

    % Filter invalid data.
    locRemove = ismissing(y) | isinf(y);

    x(locRemove) = [];
    y(locRemove) = [];

    % Find non-contiguous time-periods.
    idxChange = find(diff(x) > seconds(1)) + 1;
    idxChange = [1; idxChange; numel(x) + 1];

    [f, t, p] = deal([]);

    % Loop over each time period, and compute individual
    % spectrogram.
    for i = 1:(numel(idxChange) - 1)

        idxPeriod = idxChange(i):(idxChange(i + 1) - 1);
        x_ = x(idxPeriod);
        y_ = y(idxPeriod);

        % Compute spectrogram coefficients.
        rate = round(1 / mode(seconds(diff(x_))));

        if ~ismissing(options.Window)
            w = options.Window;
        elseif rate > 100
            w = 25;
        else
            w = 5;
        end

        window = rate * w;
        overlap = round(window * options.Overlap);

        if window > numel(y_)
            window = [];
        end

        if overlap >= numel(y_)
            overlap = [];
        end

        % Spectrogram.
        [~, f_, t_, p_] = spectrogram(y_, window, overlap, 2 * options.FrequencyPoints, rate);
        t_ = x_(1) + seconds(t_);

        f = f_;
        t = [t, t_(1) - mag.time.Constant.Eps, t_]; %#ok<AGROW>
        p = [p, NaN(numel(f), 1), p_]; %#ok<AGROW>
    end

    if ~any(ismissing(options.FrequencyLimits))

        locF = (f >= options.FrequencyLimits(1)) & (f <= options.FrequencyLimits(2));
        f = f(locF);
        p = p(locF, :);
    end
end
