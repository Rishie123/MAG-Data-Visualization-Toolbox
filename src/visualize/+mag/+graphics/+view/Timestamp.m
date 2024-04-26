classdef Timestamp < mag.graphics.view.Science
% TIMESTAMP Show analysis of science and I-ALiRT timestamps.

    methods

        function this = Timestamp(results, options)

            arguments
                results
                options.?mag.graphics.view.Timestamp
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            [primarySensor, secondarySensor] = this.getSensorNames();

            primaryScience = this.Results.Primary;
            secondaryScience = this.Results.Secondary;

            % Plot difference in science timestamp.
            matchedSecondaryTime = this.retrieveMatchingTimestamps(primaryScience.Time, secondaryScience.Time, Threshold = 1e2);
            matchedPrimaryTime = this.retrieveMatchingTimestamps(secondaryScience.Time, primaryScience.Time, Threshold = 1e2);

            primaryComparison = table(primaryScience.Time, matchedSecondaryTime, VariableNames = ["p", "s"]);
            secondaryComparison = table(secondaryScience.Time, matchedPrimaryTime, VariableNames = ["s", "p"]);

            this.Figures(1) = mag.graphics.visualize( ...
                primaryComparison, ...
                mag.graphics.style.Default(Title = "Primary vs. Secondary", YLabel = "\Deltat [ms]", YScale = "log", Layout = [2, 1], Charts = mag.graphics.chart.Plot(XVariable = "p", YVariables = this.getScienceTimingOperation("p", "s"))), ...
                secondaryComparison, ...
                mag.graphics.style.Default(Title = "Secondary vs. Primary", YLabel = "\Deltat [ms]", YScale = "log", Layout = [2, 1], Charts = mag.graphics.chart.Plot(XVariable = "s", YVariables = this.getScienceTimingOperation("s", "p"))), ...
                primaryScience.Events, mag.graphics.style.Default(Title = compose("%s Modes", primarySensor), YLabel = "mode [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency", EndTime = primaryScience.Time(end))), ...
                secondaryScience.Events, mag.graphics.style.Default(Title = compose("%s Modes", secondarySensor), YLabel = "mode [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency", EndTime = secondaryScience.Time(end))), ...
                Name = "Science Timestamp Analysis", ...
                Arrangement = [6, 1], ...
                LinkXAxes = true, ...
                WindowState = "maximized");

            % Plot difference in I-ALiRT timestamp.
            if ~isempty(this.Results.IALiRT)

                primaryIALiRT = this.Results.IALiRT.Primary;
                secondaryIALiRT = this.Results.IALiRT.Secondary;

                if numel(primaryIALiRT.Time) == numel(secondaryIALiRT.Time)

                    primaryScienceTime = this.retrieveMatchingTimestamps(primaryIALiRT.Time, primaryScience.Time, Threshold = 1e3);
                    secondaryScienceTime = this.retrieveMatchingTimestamps(secondaryIALiRT.Time, secondaryScience.Time, Threshold = 1e3);

                    timestampComparison = table(primaryScienceTime, primaryIALiRT.Time, secondaryScienceTime, secondaryIALiRT.Time, ...
                        VariableNames = ["ps", "pi", "ss", "si"]);

                    this.Figures(2) = mag.graphics.visualize( ...
                        timestampComparison, ...
                        [mag.graphics.style.Default(Title = "I-ALiRT FOB vs. FIB", YLabel = "\Deltat [ms]", Layout = [2, 1], Charts = mag.graphics.chart.Plot(XVariable = "pi", YVariables = this.getIALIRTTimingOperation("pi", "si"))), ...
                        mag.graphics.style.Default(Title = "Primary Science vs. I-ALiRT", YLabel = "\Deltat [ms]", Layout = [2, 1], Charts = mag.graphics.chart.Plot(XVariable = "ps", YVariables = this.getIALIRTTimingOperation("ps", "pi"))), ...
                        mag.graphics.style.Default(Title = "Secondary Science vs. I-ALiRT", YLabel = "\Deltat [ms]", Layout = [2, 1], Charts = mag.graphics.chart.Plot(XVariable = "ss", YVariables = this.getIALIRTTimingOperation("ss", "si")))], ...
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
    end
    
    methods (Static, Access = private)

        function matchedTimeB = retrieveMatchingTimestamps(timeA, timeB, options)

            arguments
                timeA (1, :) datetime
                timeB (1, :) datetime
                options.Threshold (1, 1) double = 1e3
            end

            % Pre-allocate array.
            matchedTimeB = repmat(datetime("Inf", TimeZone = "UTC"), [numel(timeA), 1]);

            % Find location of first match.
            [~, idxMin] = min(abs(timeA(1) - timeB));
            matchedTimeB(1) = timeB(idxMin);

            % Loop over all subsequent matches, now that we know the first
            % one.
            for i = 2:numel(timeA)

                idxStart = idxMin - options.Threshold;
                idxEnd = idxMin + options.Threshold;

                if idxStart < 1
                    idxStart = 1;
                end

                if idxEnd > numel(timeB)
                    idxEnd = numel(timeB);
                end

                [~, idxMin] = min(abs(timeA(i) - timeB(idxStart:idxEnd)));
                idxMin = idxMin + idxStart - 1;

                matchedTimeB(i) = timeB(idxMin);
            end
        end

        function action = getScienceTimingOperation(y1, y2)

            action = mag.graphics.operation.Composition(Operations = [ ...
                mag.graphics.operation.Subtract(Minuend = y1, Subtrahend = y2), ...
                mag.graphics.operation.Convert(Conversion = @milliseconds), ...
                mag.graphics.operation.Convert(Conversion = @abs)]);
        end

        function action = getIALIRTTimingOperation(y1, y2)

            action = mag.graphics.operation.Composition(Operations = [ ...
                mag.graphics.operation.Subtract(Minuend = y1, Subtrahend = y2), ...
                mag.graphics.operation.Convert(Conversion = @milliseconds)]);
        end
    end
end
