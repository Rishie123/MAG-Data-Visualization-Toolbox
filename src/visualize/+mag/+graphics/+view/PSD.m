classdef PSD < mag.graphics.view.View
% PSD Show PSD of magnetic field for each specified event.

    properties
        % NAME Figure name.
        Name string {mustBeScalarOrEmpty} = missing()
        % EVENT Event name to show.
        Event (1, 1) string {mustBeMember(Event, ["DataFrequency", "Range"])}
    end

    methods

        function this = PSD(results, options)

            arguments
                results
                options.?mag.graphics.view.PSD
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            primaryData = this.computeEventBasedPSD(this.Results.Primary);
            secondaryData = this.computeEventBasedPSD(this.Results.Secondary);

            charts = cell(2, numel(primaryData));
            charts(:, 1:2:end) = reshape(primaryData, 2, []);
            charts(:, 2:2:end) = reshape(secondaryData, 2, []);

            this.Figures = mag.graphics.visualize( ...
                charts{:}, ...
                Name = this.getFigureName(), ...
                LinkXAxes = false, ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function charts = computeEventBasedPSD(this, data)

            charts = {};
            yLine = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10pT");

            events = data.Events(data.Events.Reason == "Command", :);
            interestingEvents = events(ismember(events.(this.Event), unique(events.(this.Event))), :);

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
                        mag.graphics.style.Default(Title = this.getFigureTitle(data.MetaData, interestingEvents.Label(i), startTime, duration), ...
                        XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], ...
                        Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine])}]; %#ok<AGROW>
                end
            end
        end

        function value = getFigureName(this)

            if ismissing(this.Name)
                value = compose("%s PSD Analysis", this.Event);
            else
                value = this.Name;
            end
        end
    end

    methods (Static, Access = private)

        function value = getFigureTitle(metaData, label, startTime, duration)
            value = compose("%s %s (%s, %s)", metaData.getDisplay("Sensor"), label, datestr(startTime, "dd-mmm-yy HH:MM"), duration); %#ok<DATST>
        end
    end
end
