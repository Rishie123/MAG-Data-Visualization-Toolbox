classdef IALiRT < mag.graphics.view.Science
% IALiRT Show IALiRT.

    methods

        function this = IALiRT(results, options)

            arguments
                results
                options.?mag.graphics.view.IALiRT
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            primary = this.Results.IALiRT.Primary;
            secondary = this.Results.IALiRT.Secondary;

            this.Figures = mag.graphics.visualize( ...
                primary, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(primary), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"])), ...
                secondary, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(secondary), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"])), ...
                Title = this.getFigureTitle(primary, secondary), ...
                Name = this.getFigureName(primary, secondary), ...
                Arrangement = [1, 2], ...
                LinkXAxes = true, ...
                WindowState = "maximized");
        end
    end
end
