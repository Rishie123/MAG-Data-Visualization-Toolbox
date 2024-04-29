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
        options.GlobalLegend (1, :) string = string.empty()
        options.LinkXAxes (1, 1) logical = false
        options.LinkYAxes (1, 1) logical = false
        options.TileIndexing (1, 1) string {mustBeMember(options.TileIndexing, ["columnmajor", "rowmajor"])} = "rowmajor"
        options.WindowState (1, 1) string {mustBeMember(options.WindowState, ["normal", "maximized", "minimized", "fullscreen"])} = "normal"
        options.ShowVersion (1, 1) logical = false
        options.Visible (1, 1) logical = true
    end

    arguments (Output)
        f (1, 1) matlab.ui.Figure
    end

    % Force MATLAB to finish opening any previous figure.
    drawnow();

    % Create and populate figure.
    % Make sure figure is hidden while being populated, and only shown, if
    % requested, at the end.
    f = figure(Name = options.Name, NumberTitle = "off", WindowState = options.WindowState, Visible = "off");
    setVisibility = onCleanup(@() set(f, Visible = matlab.lang.OnOffSwitchState(options.Visible)));

    if isequal(options.Arrangement, zeros(1, 2))
        arrangement = {"flow"};
    else
        arrangement = num2cell(options.Arrangement);
    end

    if isequal(options.TileIndexing, "columnmajor")
        spacing = "compact";
    else
        spacing = "tight";
    end

    t = tiledlayout(f, arrangement{:}, TileSpacing = spacing, TileIndexing = options.TileIndexing);
    t.Title.String = options.Title;

    axes = matlab.graphics.axis.Axes.empty();

    for i = 1:numel(data)

        ax = doVisualize(t, data{i}, styles{i});
        axes = horzcat(axes, ax); %#ok<AGROW>
    end

    if ~isempty(options.GlobalLegend)

        l = legend(ax(1), options.GlobalLegend, Orientation = "horizontal");
        l.Layout.Tile = "south";
    end

    if options.LinkXAxes
        linkaxes(axes, "x");
    end

    if options.LinkYAxes
        linkaxes(axes, "y");
    end

    if options.ShowVersion
        annotation(f, "textbox", String = compose("v%s", mag.version()), LineStyle = "none", Units = "pixels", Position = [0, 25, 0, 0]);
    end
end

function axes = doVisualize(t, data, styles)
% DOVISUALIZE Internal plotting function to handle different chart option
% types.

    arguments (Input)
        t (1, 1) matlab.graphics.layout.TiledChartLayout
        data {mustBeA(data, ["mag.Data", "tabular"])}
        styles (1, :) mag.graphics.style.Axes
    end

    axes = matlab.graphics.axis.Axes.empty();

    for i = 1:numel(styles)

        ax = nexttile(t, styles(i).Layout);
        ax = styles(i).assemble(t, ax, data);

        axes = horzcat(axes, ax); %#ok<AGROW>
    end
end
