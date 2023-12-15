function savePlots(figures, location)
% SAVEPLOTS Save plots at specified location.

    arguments
        figures (1, :) matlab.ui.Figure
        location (1, 1) string {mustBeFolder} = "results"
    end

    for f = figures

        if isvalid(f)

            name = fullfile(location, f.Name);

            savefig(f, name);
            exportgraphics(f, fullfile(name + ".png"), Resolution = 300);
        end
    end
end
