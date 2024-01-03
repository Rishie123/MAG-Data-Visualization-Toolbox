function savePlots(figures, location, options)
% SAVEPLOTS Save plots at specified location.

    arguments
        figures (1, :) matlab.ui.Figure
        location (1, 1) string {mustBeFolder} = "results"
        options.DotReplacement (1, 1) string = "_"
    end

    for f = figures

        if isvalid(f)

            name = replace(fullfile(location, f.Name), ".", options.DotReplacement);

            savefig(f, name);
            exportgraphics(f, fullfile(name + ".png"), Resolution = 300);
        end
    end
end
