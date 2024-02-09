function ax = getAllAxes(f)
% GETALLAXES Get all axes of the figure.

    arguments (Input)
        f (1, 1) {mustBeA(f, ["matlab.ui.Figure", "matlab.graphics.layout.TiledChartLayout"])}
    end

    arguments (Output)
        ax (:, 1) matlab.graphics.axis.Axes
    end

    % Get all direct axes.
    ax = findobj(f, Type = "Axes");

    % Get any stacked plot.
    s = findobj(f, Type = "Stackedplot");

    if ~isempty(s)
        ax = [ax; findobj([s.NodeChildren], Type = "Axes")];
    end
end
