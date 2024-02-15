function ax = getAllAxes(obj)
% GETALLAXES Get all axes of the figure.

    arguments (Input)
        obj (1, 1) {mustBeA(obj, ["matlab.ui.Figure", "matlab.graphics.layout.TiledChartLayout"])}
    end

    arguments (Output)
        ax (:, 1) matlab.graphics.axis.Axes
    end

    % Get all direct axes.
    ax = findobj(obj, Type = "Axes");

    % Get any stackedplot or scatterhistogram.
    ax = [ax; findSpecialType(obj, "Stackedplot", "NodeChildren")];
    ax = [ax; findSpecialType(obj, "Scatterhistogram", "NodeChildren")];

    % Remove invalid handles.
    ax(~isvalid(ax)) = [];

    % If no axes found, make sure type is correct.
    if isempty(ax)
        ax = matlab.graphics.axis.Axes.empty();
    end
end

function ax = findSpecialType(obj, type, property)

    s = findobj(obj, Type = type);

    if isempty(s)
        ax = matlab.graphics.axis.Axes.empty();
    else
        ax = findobj([s.(property)], Type = "Axes");
    end
end
