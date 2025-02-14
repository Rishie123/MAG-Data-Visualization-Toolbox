classdef HK < mag.graphics.view.View
% HK Show HK of instrument.

    properties (Constant, Access = private)
        % VOFFSET Offset for voltage y-axis limits.
        VOffset (1, 2) double = [-0.1, 0.1]
    end

    methods

        function this = HK(results, options)

            arguments
                results
                options.?mag.graphics.view.HK
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            [primarySensor, secondarySensor] = this.getSensorNames();
            pwr = this.getHKType("PW");

            if isempty(pwr) || ~pwr.HasData
                return;
            end

            primary = this.Results.Primary;
            secondary = this.Results.Secondary;

            % HK time series.
            this.Figures(1) = this.Factory.assemble( ...
                pwr, ...
                [mag.graphics.style.LeftRight(Title = "1.5 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 1.5 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P1V5V"), mag.graphics.chart.Plot(YVariables = "P1V5I")]), ...
                mag.graphics.style.LeftRight(Title = "1.8 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 1.8 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P1V8V"), mag.graphics.chart.Plot(YVariables = "P1V8I")]), ...
                mag.graphics.style.LeftRight(Title = "3.3 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 3.3 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P3V3V"), mag.graphics.chart.Plot(YVariables = "P3V3I")]), ...
                mag.graphics.style.LeftRight(Title = "2.5 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 2.5 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P2V5V"), mag.graphics.chart.Plot(YVariables = "P2V5I")]), ...
                mag.graphics.style.LeftRight(Title = "+8 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "P8V"), mag.graphics.chart.Plot(YVariables = "P8VI")]), ...
                mag.graphics.style.LeftRight(Title = "-8 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "N8V"), mag.graphics.chart.Plot(YVariables = "N8VI")]), ...
                mag.graphics.style.Default(Title = "2.4 V", YLabel = "[V]", Charts = mag.graphics.chart.Plot(YVariables = "P2V4V")), ...
                mag.graphics.style.Stackedplot(Title = "Ranges", YLabels = ["MAGo [-]", "MAGi [-]"], YAxisLocation = "right", RotateLabels = true,  Charts = mag.graphics.chart.Stackedplot(YVariables = ["MAGoRange", "MAGiRange"])), ...
                mag.graphics.style.Stackedplot(Title = "Saturation", YLabels = ["MAGo x [-]", "MAGo y [-]", "MAGo z [-]", "MAGi x [-]", "MAGi y [-]", "MAGi z [-]"], RotateLabels = true, Layout = [2, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["MAGoSatFlagX", "MAGoSatFlagY", "MAGoSatFlagZ", "MAGiSatFlagX", "MAGiSatFlagY", "MAGiSatFlagZ"])), ...
                mag.graphics.style.Stackedplot(Title = "Temperature", YLabels = ["ICU " + this.TLabel, primarySensor + " " + this.TLabel, secondarySensor + " " + this.TLabel], YAxisLocation = "right", RotateLabels = true, Layout = [2, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["ICU", primarySensor, secondarySensor] + "Temperature"))], ...
                Name = "HK Time Series", ...
                Arrangement = [6, 2], ...
                LinkXAxes = true, ...
                WindowState = "maximized");

            % Close up of HK.
            scienceStartTime = min(primary.Time(1), secondary.Time(1));
            scienceEndTime = max(primary.Time(end), secondary.Time(end));

            voltsHK = pwr.copy();
            voltsHK.Data = voltsHK.Data(timerange(scienceStartTime, scienceEndTime, "closed"), :);

            this.Figures(2) = this.Factory.assemble( ...
                voltsHK, ...
                [mag.graphics.style.LeftRight(Title = "+8 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "P8V"), mag.graphics.chart.Plot(YVariables = "P8VI")]), ...
                mag.graphics.style.LeftRight(Title = "-8 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "N8V"), mag.graphics.chart.Plot(YVariables = "N8VI")]), ...
                mag.graphics.style.LeftRight(Title = "2.5 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "P2V5V"), mag.graphics.chart.Plot(YVariables = "P2V5I")])], ...
                Title = compose("From: (t_{0} + %s) - To: (t_{end} - %s)", string(scienceStartTime - pwr.Time(1)), string(abs(pwr.Time(end) - scienceEndTime))), ...
                Name = "+-8V Close Up", ...
                Arrangement = [3, 1], ...
                LinkXAxes = true, ...
                WindowState = "maximized");

            % HK and modes.
            if ~isempty(primary.Events) && ~isempty(secondary.Events)

                this.Figures(end + 1) = this.Factory.assemble( ...
                    pwr, ...
                    [mag.graphics.style.LeftRight(Title = "1.5 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 1.5 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P1V5V"), mag.graphics.chart.Plot(YVariables = "P1V5I")]), ...
                    mag.graphics.style.LeftRight(Title = "1.8 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 1.8 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P1V8V"), mag.graphics.chart.Plot(YVariables = "P1V8I")]), ...
                    mag.graphics.style.LeftRight(Title = "3.3 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 3.3 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P3V3V"), mag.graphics.chart.Plot(YVariables = "P3V3I")]), ...
                    mag.graphics .style.Default(Title = "2.4 V", YLabel = "[V]", YAxisLocation = "right", Charts = mag.graphics.chart.Plot(YVariables = "P2V4V"))], ...
                    primary.Events, mag.graphics.style.Default(Title = compose("%s Modes", primarySensor), YLabel = "mode [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency", EndTime = primary.Time(end))), ...
                    secondary.Events, mag.graphics.style.Default(Title = compose("%s Modes", secondarySensor), YLabel = "mode [-]", YLimits = "manual", YAxisLocation = "right", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency", EndTime = secondary.Time(end))), ...
                    primary.Events, mag.graphics.style.Default(Title = compose("%s Ranges", primarySensor), YLabel = "range [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Range", YOffset = 0.1, IgnoreMissing = false, EndTime = primary.Time(end))), ...
                    secondary.Events, mag.graphics.style.Default(Title = compose("%s Ranges", secondarySensor), YLabel = "range [-]", YLimits = "manual", YAxisLocation = "right", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Range", YOffset = 0.1, IgnoreMissing = false, EndTime = secondary.Time(end))), ...
                    Name = "HK & Events", ...
                    Arrangement = [4, 2], ...
                    LinkXAxes = true, ...
                    WindowState = "maximized");
            end

            % Processor HK.
            sid15 = this.getHKType("SID15");
            procstat = this.getHKType("PROCSTAT");

            if ~isempty(sid15) && ~isempty(procstat)

                drt = sid15.get("FOBDataReadyTime", "FIBDataReadyTime");
                drt = timetable(sid15.Time, 1000 * (drt(:, 1) - drt(:, 2)), VariableNames = "Difference");

                this.Figures(end + 1) = this.Factory.assemble( ...
                    procstat, mag.graphics.style.Default(Title = "Messages in Queue", YLabel = "n [-]", Legend = ["FOB", "FIB"], Charts = [mag.graphics.chart.Plot(YVariables = "FOBQueueNumMSG"), mag.graphics.chart.Plot(YVariables = "FIBQueueNumMSG")]), ...
                    drt, mag.graphics.style.Default(Title = "Data Ready Time", YLabel = "\Delta Data Ready Time [ms]", Charts = mag.graphics.chart.Plot(YVariables = "Difference")), ...
                    Name = "Processor Stats", ...
                    Arrangement = [2, 1], ...
                    LinkXAxes = true);
            end
        end
    end
end
