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

            % Plot difference in timestamp.
            if numel(primaryIALiRT.Time) == numel(secondaryIALiRT.Time)

                [primarySensor, secondarySensor] = this.getSensorNames();

                primaryScienceTime = this.retrieveMatchingTimestamps(primaryIALiRT.Time, primaryScience.Time);
                secondaryScienceTime = this.retrieveMatchingTimestamps(secondaryIALiRT.Time, secondaryScience.Time);

                timestampComparison = table(primaryScienceTime, primaryIALiRT.Time, secondaryScienceTime, secondaryIALiRT.Time, ...
                    VariableNames = ["ps", "pi", "ss", "si"]);

                this.Figures(4) = mag.graphics.visualize( ...
                    timestampComparison, ...
                    [mag.graphics.style.Default(Title = "I-ALiRT FOB vs. FIB", YLabel = "\Deltat [ms]", Layout = [2, 1], Charts = mag.graphics.chart.Plot(XVariable = "pi", YVariables = this.getTimingOperation("pi", "si"))), ...
                    mag.graphics.style.Default(Title = "Primary Science vs. I-ALiRT", YLabel = "\Deltat [ms]", Layout = [2, 1], Charts = mag.graphics.chart.Plot(XVariable = "ps", YVariables = this.getTimingOperation("ps", "pi"))), ...
                    mag.graphics.style.Default(Title = "Secondary Science vs. I-ALiRT", YLabel = "\Deltat [ms]", Layout = [2, 1], Charts = mag.graphics.chart.Plot(XVariable = "ss", YVariables = this.getTimingOperation("ss", "si")))], ...
                    primaryScience.Events, mag.graphics.style.Default(Title = compose("%s Modes", primarySensor), YLabel = "mode [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency", EndTime = primaryScience.Time(end))), ...
                    secondaryScience.Events, mag.graphics.style.Default(Title = compose("%s Modes", secondarySensor), YLabel = "mode [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency", EndTime = secondaryScience.Time(end))), ...
                    Name = "I-ALiRT Timestamp Analysis", ...
                    Arrangement = [8, 1], ...
                    LinkXAxes = true, ...
                    WindowState = "maximized");
            else
                warning("FOB and FIB I-ALiRT do not have the same size.");
            end
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

    methods (Static, Access = private)

        function matchedScienceTime = retrieveMatchingTimestamps(iALiRTTime, scienceTime)

            % Pre-allocate array.
            matchedScienceTime = repmat(datetime("Inf", TimeZone = "UTC"), [numel(iALiRTTime), 1]);

            % Find location of first match.
            [~, idxMin] = min(abs(iALiRTTime(1) - scienceTime));
            matchedScienceTime(1) = scienceTime(idxMin);

            % Loop over all subsequent matches, now that we know the first
            % one.
            for i = 2:numel(iALiRTTime)

                prevIdxMin = idxMin;
                idxEnd = (idxMin + 1e3);

                if idxEnd > numel(scienceTime)
                    idxEnd = numel(scienceTime);
                end

                [~, idxMin] = min(abs(iALiRTTime(i) - scienceTime(idxMin:idxEnd)));
                idxMin = idxMin + prevIdxMin - 1;

                matchedScienceTime(i) = scienceTime(idxMin);
            end
        end

        function action = getTimingOperation(y1, y2)

            action = mag.graphics.operation.Composition(Operations = [ ...
                mag.graphics.operation.Subtract(Minuend = y1, Subtrahend = y2), ...
                mag.graphics.operation.Convert(Conversion = @milliseconds)]);
        end
    end
end
