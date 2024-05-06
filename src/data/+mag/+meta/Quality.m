classdef Quality < double
% QUALITY Enumeration for quality type. Used to remove data for plotting.

    enumeration
        % BAD Data point of bad quality (do not plot).
        Bad (0)
        % ARTIFICIAL Artificial data point, added during processing.
        Artificial (1)
        % REGULAR Regular data point quality.
        Regular (2)
        % NAN Missing value.
        NaN (NaN)
    end

    methods

        function value = isPlottable(this)
        % ISPLOTTABLE Determine whether data point can be plotted.
        % Excludes data points of bad quality and artificial data.

            value = this >= mag.meta.Quality.Artificial;
        end

        function value = isScience(this)
        % ISSCIENCE Determine whether data point is science.
        % Excludes bad science and artificial data.

            value = this == mag.meta.Quality.Regular;
        end
    end
end
