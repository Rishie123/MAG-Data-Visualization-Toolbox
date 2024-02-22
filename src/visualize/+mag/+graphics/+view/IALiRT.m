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
                primaryIALiRT, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(primaryIALiRT), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = primaryIALiRT.Quality)), ...
                secondaryIALiRT, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(secondaryIALiRT), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], YAxisLocation = "right", Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = primaryIALiRT.Quality)), ...
                Title = this.getFigureTitle(primaryIALiRT, secondaryIALiRT), ...
                Name = this.getFigureName(primaryIALiRT, secondaryIALiRT), ...
                Arrangement = [1, 2], ...
                LinkXAxes = true, ...
                WindowState = "maximized");

            % Plot I-ALiRT and science.
            primaryScience = this.Results.Primary;
            secondaryScience = this.Results.Secondary;

            primaryComparison = synchronize(timetable(primaryIALiRT.Time, primaryIALiRT.X, primaryIALiRT.Y, primaryIALiRT.Z, primaryIALiRT.Quality, VariableNames = ["xi", "yi", "zi", "qi"]), ...
                timetable(primaryScience.Time, primaryScience.X, primaryScience.Y, primaryScience.Z, primaryScience.Quality, VariableNames = ["xs", "ys", "zs", "qs"]), "first", "nearest");
            secondaryComparison = synchronize(timetable(secondaryIALiRT.Time, secondaryIALiRT.X, secondaryIALiRT.Y, secondaryIALiRT.Z, secondaryIALiRT.Quality, VariableNames = ["xi", "yi", "zi", "qi"]), ...
                timetable(secondaryScience.Time, secondaryScience.X, secondaryScience.Y, secondaryScience.Z, secondaryScience.Quality, VariableNames = ["xs", "ys", "zs", "qs"]), "first", "nearest");

            primaryGraphs = this.generateComparisonGraph(primaryIALiRT, primaryComparison);
            secondaryGraphs = this.generateComparisonGraph(secondaryIALiRT, secondaryComparison);

            this.Figures(2) = mag.graphics.visualize( ...
                primaryComparison, primaryGraphs, secondaryComparison, secondaryGraphs, ...
                Name = "Science vs. I-ALiRT", ...
                Arrangement = [9, 2], ...
                GlobalLegend = ["Science", "I-ALiRT"], ...
                LinkXAxes = true, ...
                TileIndexing = "columnmajor", ...
                WindowState = "maximized");

            % Plot difference in timestamp.
            [~, idxPriMin] = min(abs(primaryScience.Time - primaryIALiRT.Time'));
            [~, idxSecMin] = min(abs(secondaryScience.Time - secondaryIALiRT.Time'));

            timestampComparison = table(primaryScience.Time(idxPriMin), primaryIALiRT.Time, secondaryScience.Time(idxSecMin), secondaryIALiRT.Time, ...
                VariableNames = ["ps", "pi", "ss", "si"]);

            this.Figures(3) = mag.graphics.visualize( ...
                timestampComparison, ...
                [mag.graphics.style.Default(Title = "I-ALiRT FOB vs. FIB", YLabel = "\Deltat [ms]", Charts = mag.graphics.chart.Plot(XVariable = "pi", YVariables = this.getTimingOperation("pi", "si"))), ...
                mag.graphics.style.Default(Title = "Primary Science vs. I-ALiRT", YLabel = "\Deltat [ms]", Charts = mag.graphics.chart.Plot(XVariable = "ps", YVariables = this.getTimingOperation("ps", "pi"))), ...
                mag.graphics.style.Default(Title = "Secondary Science vs. I-ALiRT", YLabel = "\Deltat [ms]", Charts = mag.graphics.chart.Plot(XVariable = "ss", YVariables = this.getTimingOperation("ss", "si")))], ...
                Name = "I-ALiRT Timestamp Analysis", ...
                Arrangement = [3, 1], ...
                LinkXAxes = true, ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

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

    methods (Static, Access = private)

        function action = getTimingOperation(y1, y2)

            action = mag.graphics.operation.Composition(Operations = [mag.graphics.operation.Subtract(Minuend = y1, Subtrahend = y2), ...
                mag.graphics.operation.Convert(Conversion = @milliseconds)]);
        end
    end
end
