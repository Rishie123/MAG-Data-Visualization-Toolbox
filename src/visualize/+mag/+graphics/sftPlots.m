function figures = sftPlots(analysis, options)
% SFTPLOTS Create plots for SFT results.

    arguments (Input)
        analysis (1, 1) mag.IMAPTestingAnalysis
        options.Filter duration {mustBeScalarOrEmpty} = duration.empty()
        options.PSDStart datetime {mustBeScalarOrEmpty} = datetime.empty()
        options.PSDDuration (1, 1) duration = hours(1)
        options.SeparateModes (1, 1) logical = true
    end

    arguments (Output)
        figures (1, :) matlab.ui.Figure
    end

    views = mag.graphics.view.View.empty();

    % Crop data.
    if ~isempty(options.Filter)

        analysis = analysis.copy();
        analysis.Results.fillWarmUp(options.Filter);
    end

    % Separate modes.
    modes = analysis.getAllModes();

    if ~options.SeparateModes || isempty(modes)
        modes = analysis.Results;
    end

    % Show science and frequency.
    for i = 1:numel(modes)

        views(end + 1) = mag.graphics.view.Field(modes(i)); %#ok<AGROW>

        if ~isempty(options.PSDStart)
            views(end + 1) = mag.graphics.view.Frequency(modes(i), PSDStart = options.PSDStart, PSDDuration = options.PSDDuration); %#ok<AGROW>
        end
    end

    % Show HK.
    views(end + 1) = mag.graphics.view.HK(analysis.Results);

    % Generate figures.
    figures = views.visualizeAll();
end
