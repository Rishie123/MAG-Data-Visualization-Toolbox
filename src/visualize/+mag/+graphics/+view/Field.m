classdef Field < mag.graphics.view.Science
% FIELD Show magnetic field and optional HK.

    properties
        % EVENT Event name to show.
        Event string {mustBeScalarOrEmpty, mustBeMember(Event, ["Mode", "Range"])} = string.empty()
    end

    methods

        function this = Field(results, options)

            arguments
                results
                options.?mag.graphics.view.Field
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            [primarySensor, secondarySensor] = this.getSensorNames();
            hk = this.getHKType("PW");

            primary = this.Results.Primary;
            secondary = this.Results.Secondary;

            switch this.Event
                case "Mode"

                    numEvents = 1;
                    eventData = {primary, mag.graphics.style.Default(Title = compose("%s Modes", primarySensor), YLabel = "mode [-]", YLimits = "padded", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency")), ...
                        secondary, mag.graphics.style.Default(Title = compose("%s Modes", secondarySensor), YLabel = "mode [-]", YLimits = "padded", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency"))};

                case "Range"

                    numEvents = 1;
                    eventData = {primary, mag.graphics.style.Default(Title = compose("%s Ranges", primarySensor), YLabel = "range [-]", YLimits = "padded", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Range", YOffset = 0.1)), ...
                        secondary, mag.graphics.style.Default(Title = compose("%s Ranges", secondarySensor), YLabel = "range [-]", YLimits = "padded", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Range", YOffset = 0.1))};

                otherwise
                    [numEvents, eventData] = deal(0, {});
            end

            if isempty(hk)

                this.Figures = mag.graphics.visualize( ...
                    primary, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(primary), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = primary.Quality)), ...
                    secondary, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(secondary), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = secondary.Quality)), ...
                    eventData{:}, ...
                    Title = this.getFigureTitle(primary, secondary), ...
                    Name = this.getFigureName(primary, secondary), ...
                    Arrangement = [1 + numEvents, 2], ...
                    LinkXAxes = true, ...
                    WindowState = "maximized");
            else

                this.Figures = mag.graphics.visualize( ...
                    primary, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(primary), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Layout = [3, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = primary.Quality)), ...
                    secondary, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(secondary), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Layout = [3, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = secondary.Quality)), ...
                    eventData{:}, ...
                    hk, [mag.graphics.style.Default(Title = compose("%s & ICU Temperatures", primarySensor), YLabel = this.TLabel, Legend = [primarySensor, "ICU"], Charts = mag.graphics.chart.Plot(YVariables = [primarySensor, "ICU"] + "Temperature")), ...
                    mag.graphics.style.Default(Title = compose("%s & ICU Temperatures", secondarySensor), YLabel = this.TLabel, Legend = [secondarySensor, "ICU"], Charts = mag.graphics.chart.Plot(YVariables = [secondarySensor, "ICU"] + "Temperature"))], ...
                    Title = this.getFigureTitle(primary, secondary), ...
                    Name = this.getFigureName(primary, secondary), ...
                    Arrangement = [4 + numEvents, 2], ...
                    LinkXAxes = true, ...
                    WindowState = "maximized");
            end
        end
    end
end
