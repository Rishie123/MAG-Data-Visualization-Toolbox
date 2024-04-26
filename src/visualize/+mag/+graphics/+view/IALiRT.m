classdef IALiRT < mag.graphics.view.Science
% IALIRT Show IALiRT.

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

            primaryIALiRT = this.Results.IALiRT.Primary;
            secondaryIALiRT = this.Results.IALiRT.Secondary;

            % Plot only I-ALiRT.
            this.Figures(1) = mag.graphics.visualize( ...
                primaryIALiRT, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(primaryIALiRT), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = primaryIALiRT.Quality.isPlottable())), ...
                secondaryIALiRT, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(secondaryIALiRT), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], YAxisLocation = "right", Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = secondaryIALiRT.Quality.isPlottable())), ...
                Title = this.getFigureTitle(primaryIALiRT, secondaryIALiRT), ...
                Name = this.getFigureName(primaryIALiRT, secondaryIALiRT), ...
                Arrangement = [1, 2], ...
                LinkXAxes = true, ...
                WindowState = "maximized");

            % Plot I-ALiRT and science (full).
            primaryScience = this.Results.Primary;
            secondaryScience = this.Results.Secondary;

            primaryOverlay = this.generateOverlayGraph(primaryScience, primaryIALiRT);

            secondaryOverlay = this.generateOverlayGraph(secondaryScience, secondaryIALiRT);
            [secondaryOverlay{2}.YAxisLocation] = deal("right");

            this.Figures(2) = mag.graphics.visualize( ...
                primaryOverlay{:}, secondaryOverlay{:}, ...
                Name = "Science vs. I-ALiRT (Full)", ...
                Arrangement = [3, 2], ...
                GlobalLegend = ["Science", "I-ALiRT"], ...
                LinkXAxes = true, ...
                TileIndexing = "columnmajor", ...
                WindowState = "maximized");

            % Plot I-ALiRT and science (closest vector).
            primaryComparison = synchronize(timetable(primaryIALiRT.Time, primaryIALiRT.X, primaryIALiRT.Y, primaryIALiRT.Z, primaryIALiRT.Quality.isPlottable(), VariableNames = ["xi", "yi", "zi", "qi"]), ...
                timetable(primaryScience.Time, primaryScience.X, primaryScience.Y, primaryScience.Z, primaryScience.Quality.isPlottable(), VariableNames = ["xs", "ys", "zs", "qs"]), "first", "nearest");
            secondaryComparison = synchronize(timetable(secondaryIALiRT.Time, secondaryIALiRT.X, secondaryIALiRT.Y, secondaryIALiRT.Z, secondaryIALiRT.Quality.isPlottable(), VariableNames = ["xi", "yi", "zi", "qi"]), ...
                timetable(secondaryScience.Time, secondaryScience.X, secondaryScience.Y, secondaryScience.Z, secondaryScience.Quality.isPlottable(), VariableNames = ["xs", "ys", "zs", "qs"]), "first", "nearest");

            primaryGraphs = this.generateComparisonGraph(primaryIALiRT, primaryComparison);

            secondaryGraphs = this.generateComparisonGraph(secondaryIALiRT, secondaryComparison);
            [secondaryGraphs.YAxisLocation] = deal("right");

            this.Figures(3) = mag.graphics.visualize( ...
                primaryComparison, primaryGraphs, secondaryComparison, secondaryGraphs, ...
                Name = "Science vs. I-ALiRT (Closest Vector)", ...
                Arrangement = [9, 2], ...
                GlobalLegend = ["Science", "I-ALiRT"], ...
                LinkXAxes = true, ...
                TileIndexing = "columnmajor", ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function overlayGraphs = generateOverlayGraph(this, scienceData, iALiRTData)

            combinedData = outerjoin(scienceData.Data(scienceData.Quality.isPlottable(), :), iALiRTData.Data(iALiRTData.Quality.isPlottable(), :));

            overlayGraphs = {combinedData, ...
                [mag.graphics.style.Default(Title = this.getFieldTitle(iALiRTData), YLabel = "x [nT]", Charts = [mag.graphics.chart.Plot(YVariables = "x_left", Filter = ~ismissing(combinedData.x_left)), mag.graphics.chart.Scatter(YVariables = "x_right", Filter = ~ismissing(combinedData.x_right), Marker = "x")]), ...
                mag.graphics.style.Default(YLabel = "y [nT]", Charts = [mag.graphics.chart.Plot(YVariables = "y_left", Filter = ~ismissing(combinedData.y_left)), mag.graphics.chart.Scatter(YVariables = "y_right", Filter = ~ismissing(combinedData.y_right), Marker = "x")]), ...
                mag.graphics.style.Default(YLabel = "z [nT]", Charts = [mag.graphics.chart.Plot(YVariables = "z_left", Filter = ~ismissing(combinedData.z_left)), mag.graphics.chart.Scatter(YVariables = "z_right", Filter = ~ismissing(combinedData.z_right), Marker = "x")])]};
        end

        function comparisonGraphs = generateComparisonGraph(this, iALiRTData, comparisonData)

            defaultColors = colororder();

            comparisonGraphs = [mag.graphics.style.Default(Title = this.getFieldTitle(iALiRTData), YLabel = "x [nT]", Layout = [2, 1], Charts = [mag.graphics.chart.Plot(YVariables = "xs", Marker = "o", Filter = comparisonData.qs), mag.graphics.chart.Plot(YVariables = "xi", Marker = "x", Filter = comparisonData.qi)]), ...
                mag.graphics.style.Default(YLabel = "\Deltax [nT]", Charts = mag.graphics.chart.Plot(YVariables = mag.graphics.operation.Subtract(Minuend = "xs", Subtrahend = "xi"), Colors = defaultColors(3, :), Filter = comparisonData.qs & comparisonData.qi)), ...
                mag.graphics.style.Default(YLabel = "y [nT]", Layout = [2, 1], Charts = [mag.graphics.chart.Plot(YVariables = "ys", Marker = "o", Filter = comparisonData.qs), mag.graphics.chart.Plot(YVariables = "yi", Marker = "x", Filter = comparisonData.qi)]), ...
                mag.graphics.style.Default(YLabel = "\Deltay [nT]", Charts = mag.graphics.chart.Plot(YVariables = mag.graphics.operation.Subtract(Minuend = "ys", Subtrahend = "yi"), Colors = defaultColors(3, :), Filter = comparisonData.qs & comparisonData.qi)), ...
                mag.graphics.style.Default(YLabel = "z [nT]", Layout = [2, 1], Charts = [mag.graphics.chart.Plot(YVariables = "zs", Marker = "o", Filter = comparisonData.qs), mag.graphics.chart.Plot(YVariables = "zi", Marker = "x", Filter = comparisonData.qi)]), ...
                mag.graphics.style.Default(YLabel = "\Deltaz [nT]", Charts = mag.graphics.chart.Plot(YVariables = mag.graphics.operation.Subtract(Minuend = "zs", Subtrahend = "zi"), Colors = defaultColors(3, :), Filter = comparisonData.qs & comparisonData.qi))];
        end
    end
end
