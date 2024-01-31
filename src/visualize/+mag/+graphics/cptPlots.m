function figures = cptPlots(analysis, options)
% CPTPLOTS Create plots for CPT results.

    arguments
        analysis (1, 1) mag.IMAPTestingAnalysis
        options.Filter duration {mustBeScalarOrEmpty} = duration.empty()
    end

    views = mag.graphics.view.View.empty();

    % Crop data.
    if ~isempty(options.Filter)

        analysis = analysis.copy();
        analysis.Results.cropScience(options.Filter);
    end

    %% Standard Plots

    figures = mag.graphics.sftPlots(analysis, SeparateModes = false);

    %% Modes

    modeCycling = analysis.getModeCycling();
    views(end + 1) = mag.graphics.view.Field(modeCycling, Event = "Mode", Name = "Mode Cycling", Title = string.empty());

    %% Final Normal Mode

    finalNormal = analysis.getFinalNormalMode();

    if ~isempty(finalNormal) && finalNormal.HasData
        views(end + 1) = mag.graphics.view.Field(finalNormal, Name = "Normal Mode (CPT End)", Title = string.empty());
    end

    %% Ranges

    rangeCycling = analysis.getRangeCycling();

    if ~isempty(rangeCycling) && rangeCycling.HasData

        % Plot all ranges.
        views(end + 1) = mag.graphics.view.Field(rangeCycling, Event = "Range", Name = "Range Cycling", Title = string.empty());

        % Plot ranges without range 0.
        locNoRangeZero = (rangeCycling.Primary.Range ~= 0) & (rangeCycling.Secondary.Range ~= 0);

        if nnz(locNoRangeZero) > 0

            noRange0Cycling = rangeCycling.copy();
            noRange0Cycling.crop(timerange(rangeCycling.Primary.Events.Time(1), rangeCycling.Primary.Events.Time(end), "closed"), ...
                timerange(rangeCycling.Secondary.Events.Time(1), rangeCycling.Secondary.Events.Time(end), "closed"));

            views(end + 1) = mag.graphics.view.Field(noRange0Cycling, Event = "Range", Name = "Range Cycling (No Range 0)", Title = string.empty());
        end
    end

    %% Ramp

    rampMode = analysis.getRampMode();
    views(end + 1) = mag.graphics.view.RampMode(rampMode);

    %% PSD

    % primaryPSDPlotData = computeEventBasedPSD(modesPrimary, "DataFrequency");
    % secondaryPSDPlotData = computeEventBasedPSD(modesSecondary, "DataFrequency");
    % 
    % charts = cell(2, numel(primaryPSDPlotData));
    % charts(:, 1:2:end) = reshape(primaryPSDPlotData, 2, []);
    % charts(:, 2:2:end) = reshape(secondaryPSDPlotData, 2, []);
    % 
    % figures(end + 1) = mag.graphics.visualize( ...
    %     charts{:}, ...
    %     Name = "Mode Cycling PSD Analysis", ...
    %     LinkXAxes = false, ...
    %     WindowState = "maximized");
    % 
    % if ~isempty(rangesPrimary) && ~isempty(rangesSecondary)
    % 
    %     primaryPSDPlotData = computeEventBasedPSD(rangesPrimary, "Range");
    %     secondaryPSDPlotData = computeEventBasedPSD(rangesSecondary, "Range");
    % 
    %     charts = cell(2, numel(primaryPSDPlotData));
    %     charts(:, 1:2:end) = reshape(primaryPSDPlotData, 2, []);
    %     charts(:, 2:2:end) = reshape(secondaryPSDPlotData, 2, []);
    % 
    %     figures(end + 1) = mag.graphics.visualize( ...
    %         charts{:}, ...
    %         Name = "Range Cycling PSD Analysis", ...
    %         LinkXAxes = false, ...
    %         Arrangement = [4, 2], ...
    %         WindowState = "maximized");
    % end

    %% Visualize

    figures = [figures, views.visualizeAll()];
end

function charts = computeEventBasedPSD(data, eventOfInterest)

    charts = {};
    yLine = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10pT");

    events = data.Events(data.Events.Reason == "Command", :);
    interestingEvents = events(ismember(events.(eventOfInterest), unique(events.(eventOfInterest))), :);

    for i = 1:size(interestingEvents, 1)

        % Find when event takes place.
        if i == size(interestingEvents, 1)
            endTime = data.Time(end);
        else
            endTime = interestingEvents.Time(i + 1);
        end

        startTime = interestingEvents.Time(i);
        duration = endTime - startTime;

        if duration > 0

            % Compute PSD.
            psd = data.computePSD(Start = startTime, Duration = duration);

            % Add plot.
            charts = [charts, {psd, ...
                mag.graphics.style.Default(Title = sprintf("%s %s (%s, %s)", data.MetaData.getDisplay("Sensor"), interestingEvents.Label(i), datestr(startTime, "dd-mmm-yy HH:MM"), duration), ...
                XLabel = "frequency [Hz]", YLabel = "PSD [nT Hz^{-0.5}]", XScale = "log", YScale = "log", Legend = ["x", "y", "z"], ...
                Charts = [mag.graphics.chart.Plot(XVariable = "f", YVariables = ["x", "y", "z"]), yLine])}]; %#ok<DATST,AGROW>
        end
    end
end
