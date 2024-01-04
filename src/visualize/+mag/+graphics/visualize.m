function f = visualize(data, styles, options)
% VISUALIZE Plot science and HK data against time, with specified figure
% options.

    arguments (Input, Repeating)
        data {mustBeA(data, ["mag.Data", "table", "timetable"])}
        styles (1, :) mag.graphics.style.Axes
    end

    arguments (Input)
        options.Name (1, 1) string = "MAG Time Series"
        options.Title string {mustBeScalarOrEmpty} = string.empty()
        options.Arrangement (1, 2) double = zeros(1, 2)
        options.LinkXAxes (1, 1) logical = false
        options.LinkYAxes (1, 1) logical = false
        options.WindowState (1, 1) string {mustBeMember(options.WindowState, ["normal", "maximized", "minimized", "fullscreen"])} = "normal"
        options.Visible (1, 1) logical = true
    end

    arguments (Output)
        f (1, 1) matlab.ui.Figure
    end

    % Force MATLAB to finish opening any previous figure.
    drawnow();

    % Create and populate figure.
    f = figure(Name = options.Name, NumberTitle = "off", WindowState = options.WindowState, Visible = matlab.lang.OnOffSwitchState(options.Visible));

    if isequal(options.Arrangement, zeros(1, 2))
        arrangement = {"flow"};
    else
        arrangement = num2cell(options.Arrangement);
    end

    t = tiledlayout(f, arrangement{:}, TileSpacing = "tight");
    t.Title.String = options.Title;

    axes = matlab.graphics.axis.Axes.empty();

    for i = 1:numel(data)

        ax = doVisualize(t, data{i}, styles{i});
        axes = horzcat(axes, ax); %#ok<AGROW>
    end

    if options.LinkXAxes
        linkaxes(axes, "x");
    end

    if options.LinkYAxes
        linkaxes(axes, "y");
    end
end

function axes = doVisualize(t, data, styles)
% DOVISUALIZE Internal plotting function to handle different chart option
% types.

    arguments (Input)
        t (1, 1) matlab.graphics.layout.TiledChartLayout
        data {mustBeA(data, ["mag.Data", "table", "timetable"])}
        styles (1, :) mag.graphics.style.Axes
    end

    axes = matlab.graphics.axis.Axes.empty();

    for i = 1:numel(styles)

        ax = nexttile(t, styles(i).Layout);
        ax = styles(i).assemble(t, ax, data);

        axes = horzcat(axes, ax); %#ok<AGROW>
    end
end
