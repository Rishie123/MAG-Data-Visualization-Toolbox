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

            if isempty(pwr)
                return;
            end

            primary = this.Results.Primary;
            secondary = this.Results.Secondary;

            % HK time series.
            this.Figures(1) = mag.graphics.visualize( ...
                pwr, ...
                [mag.graphics.style.LeftRight(Title = "1.5 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 1.5 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P1V5V"), mag.graphics.chart.Plot(YVariables = "P1V5I")]), ...
                mag.graphics.style.LeftRight(Title = "1.8 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 1.8 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P1V8V"), mag.graphics.chart.Plot(YVariables = "P1V8I")]), ...
                mag.graphics.style.LeftRight(Title = "3.3 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 3.3 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P3V3V"), mag.graphics.chart.Plot(YVariables = "P3V3I")]), ...
                mag.graphics.style.LeftRight(Title = "2.5 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 2.5 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P2V5V"), mag.graphics.chart.Plot(YVariables = "P2V5I")]), ...
                mag.graphics.style.LeftRight(Title = "+8 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "P8V"), mag.graphics.chart.Plot(YVariables = "P8VI")]), ...
                mag.graphics.style.LeftRight(Title = "-8 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "N8V"), mag.graphics.chart.Plot(YVariables = "N8VI")]), ...
                mag.graphics.style.Default(Title = "2.4 V", YLabel = "[V]", Charts = mag.graphics.chart.Plot(YVariables = "P2V4V")), ...
                mag.graphics.style.Stackedplot(Title = "Ranges", YLabels = ["MAGo [-]", "MAGi [-]"], RotateLabels = true,  Charts = mag.graphics.chart.Stackedplot(YVariables = ["MAGORANGE", "MAGIRANGE"])), ...
                mag.graphics.style.Stackedplot(Title = "Saturation", YLabels = ["MAGo x [-]", "MAGo y [-]", "MAGo z [-]", "MAGi x [-]", "MAGi y [-]", "MAGi z [-]"], RotateLabels = true, Layout = [2, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["MAGOSATFLAGX", "MAGOSATFLAGY", "MAGOSATFLAGZ", "MAGISATFLAGX", "MAGISATFLAGY", "MAGISATFLAGZ"])), ...
                mag.graphics.style.Stackedplot(Title = "Temperature", YLabels = ["ICU " + this.TLabel, primarySensor + " " + this.TLabel, secondarySensor + " " + this.TLabel], RotateLabels = true, Layout = [2, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["ICU_TEMP", primarySensor + "_TEMP", secondarySensor + "_TEMP"]))], ...
                Name = "HK Time Series", ...
                Arrangement = [6, 2], ...
                LinkXAxes = true, ...
                WindowState = "maximized");

            % Close up of HK.
            scienceStartTime = min(primary.Time(1), secondary.Time(1));
            scienceEndTime = max(primary.Time(end), secondary.Time(end));

            voltsHK = pwr.copy();
            voltsHK.Data = voltsHK.Data(timerange(scienceStartTime, scienceEndTime, "closed"), :);

            this.Figures(2) = mag.graphics.visualize( ...
                voltsHK, ...
                [mag.graphics.style.LeftRight(Title = "+8 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "P8V"), mag.graphics.chart.Plot(YVariables = "P8VI")]), ...
                mag.graphics.style.LeftRight(Title = "-8 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "N8V"), mag.graphics.chart.Plot(YVariables = "N8VI")]), ...
                mag.graphics.style.LeftRight(Title = "2.5 V", LeftLabel = "[V]", RightLabel = "[mA]", Charts = [mag.graphics.chart.Plot(YVariables = "P2V5V"), mag.graphics.chart.Plot(YVariables = "P2V5I")])], ...
                Title = sprintf("From: (t_{0} + %s) - To: (t_{end} - %s)", string(scienceStartTime - pwr.Time(1)), string(scienceEndTime - pwr.Time(end))), ...
                Name = "+-8V Close Up", ...
                Arrangement = [3, 1], ...
                LinkXAxes = true, ...
                WindowState = "maximized");

            % HK and modes.
            if ~isempty(primary.Events) && ~isempty(secondary.Events)

                this.Figures(3) = mag.graphics.visualize( ...
                    pwr, ...
                    [mag.graphics.style.LeftRight(Title = "1.5 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 1.5 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P1V5V"), mag.graphics.chart.Plot(YVariables = "P1V5I")]), ...
                    mag.graphics.style.LeftRight(Title = "1.8 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 1.8 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P1V8V"), mag.graphics.chart.Plot(YVariables = "P1V8I")]), ...
                    mag.graphics.style.LeftRight(Title = "3.3 V", LeftLabel = "[V]", RightLabel = "[mA]", LLimits = 3.3 + this.VOffset, Charts = [mag.graphics.chart.Plot(YVariables = "P3V3V"), mag.graphics.chart.Plot(YVariables = "P3V3I")]), ...
                    mag.graphics .style.Default(Title = "2.4 V", YLabel = "[V]", Charts = mag.graphics.chart.Plot(YVariables = "P2V4V"))], ...
                    primary, mag.graphics.style.Default(Title = compose("%s Modes", primarySensor), YLabel = "mode [-]", YLimits = "padded", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency")), ...
                    secondary, mag.graphics.style.Default(Title = compose("%s Modes", secondarySensor), YLabel = "mode [-]", YLimits = "padded", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency")), ...
                    primary, mag.graphics.style.Default(Title = compose("%s Ranges", primarySensor), YLabel = "range [-]", YLimits = "padded", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Range", YOffset = 0.1, IgnoreMissing = false)), ...
                    secondary, mag.graphics.style.Default(Title = compose("%s Ranges", secondarySensor), YLabel = "range [-]", YLimits = "padded", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Range", YOffset = 0.1, IgnoreMissing = false)), ...
                    Name = "HK & Events", ...
                    Arrangement = [4, 2], ...
                    LinkXAxes = true, ...
                    WindowState = "maximized");
            end

            % Processor HK.
            procstat = this.getHKType("PROCSTAT");

            if ~isempty(procstat)

                this.Figures(4) = mag.graphics.visualize( ...
                    procstat, mag.graphics.style.Default(Title = "Messages in Queue", YLabel = "n [-]", Legend = ["FOB", "FIB"], Charts = [mag.graphics.chart.Plot(YVariables = "OBNQ_NUM_MSG"), mag.graphics.chart.Plot(YVariables = "IBNQ_NUM_MSG")]), ...
                    Name = "Processor Stats", ...
                    LinkXAxes = true);
            end
        end
    end
end
