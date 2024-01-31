classdef Event < mag.graphics.chart.Chart
% EVENT Custom chart for plotting of events.

    properties
        % EVENTOFINTEREST Event name to plot.
        EventOfInterest (1, 1) string
        % YOFFSET Offset of label describing y-axis value.
        YOffset (1, 1) double = 1
        % IGNOREMISSING Ignore missing values.
        IgnoreMissing (1, 1) logical = true
        % COMBINEEVENETS Combine events with equal values.
        CombineEvents (1, 1) logical = true
    end

    methods

        function this = Event(options)

            arguments
                options.?mag.graphics.chart.custom.Event
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, ~)

            arguments (Input)
                this
                data {mustBeA(data, ["mag.TimeSeries", "timetable"])}
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            if isa(data, "mag.TimeSeries")
                data = data.Data;
            end

            hold(axes, "on");
            resetAxesHold = onCleanup(@() hold(axes, "off"));

            % Process data.
            events = data.Properties.Events;

            if this.IgnoreMissing
                interestingEvents = events(~ismissing(events.(this.EventOfInterest)), :);
            else
                interestingEvents = events;
            end

            if this.CombineEvents

                locCombine = ([NaN; diff(interestingEvents.(this.EventOfInterest))] == 0);
                interestingEvents(locCombine, :) = [];
            end

            time = interestingEvents.Time;
            variable = interestingEvents.(this.EventOfInterest);

            plotTime = repmat(datetime("now", TimeZone = "UTC"), 2 * numel(time), 1);
            plotTime(1:2:end) = time;
            plotTime(2:2:end) = [time(2:end); data.(data.Properties.DimensionNames{1})(end)];
            plotTime = reshape(plotTime, 2, []);

            plotVariable = zeros(2 * numel(variable), 1);
            plotVariable(1:2:end) = variable;
            plotVariable(2:2:end) = variable;
            plotVariable = reshape(plotVariable, 2, []);

            % Plot lines.
            plotColors = this.getColors(variable);

            for i = 1:numel(variable)
                graph(i) = plot(axes, plotTime(:, i), plotVariable(:, i), Color = plotColors(i, :), LineWidth = 3.5); %#ok<AGROW>
            end

            % Plot vertical lines between mode changes.
            xline(axes, time, "--");

            % Plot text annotation.
            for i = 1:numel(graph)
                text(axes, mean(graph(i).XData), this.YOffset + variable(i), num2str(variable(i)), HorizontalAlignment = "center", VerticalAlignment = "bottom");
            end

            % Plot ramp mode.
            locMissing = ismissing(variable);

            if any(locMissing)

                v = 0.5;
                t = "Ramp";

                for i = find(locMissing')
                    text(axes, mean(graph(i).XData), v, t, HorizontalAlignment = "center", VerticalAlignment = "middle", Rotation = 90);
                end
            end

            % Turn y-axis logarithmic.
            [s, l] = bounds(variable);

            if ((l/s) > 10) && (range(variable) > 10)
                yscale(axes, "log");
            end
        end
    end

    methods (Static, Access = private)

        function colors = getColors(variable)

            defaultColors = colororder();
            [~, ~, idxUnique] = unique(variable);

            colors = zeros(numel(variable), 3);

            for i = 1:numel(idxUnique)
                colors(i, :) = defaultColors(idxUnique(i), :);
            end
        end
    end
end
