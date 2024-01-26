function savePlots(figures, location, options)
% SAVEPLOTS Save plots at specified location.

    arguments
        figures (1, :) matlab.ui.Figure
        location (1, 1) string {mustBeFolder} = "results"
        options.ColonReplacement (1, 1) string = ""
        options.DotReplacement (1, 1) string = "_"
        options.SaveAsFig (1, 1) logical = true
    end

    for f = figures

        if isvalid(f)

            name = replace(f.Name, [":", "."], [options.ColonReplacement, options.DotReplacement]);
            name = fullfile(location, name);

            exportgraphics(f, fullfile(name + ".png"), Resolution = 300);

            if options.ExportFig

                try
                    savefig(f, name);
                catch exception
                    warning("Could not save figure ""%s"":\n%s", f.Name, exception.message);
                end
            end
        end
    end
end
