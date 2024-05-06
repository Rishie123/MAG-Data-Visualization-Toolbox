classdef Frequency < mag.graphics.view.View
% FREQUENCY Show PSD and spectrogram of magnetic field.

    properties
        % PSDSTART Start date of PSD plot.
        PSDStart (1, 1) datetime = NaT(TimeZone = "UTC")
        % PSDDURATION Duration of PSD plot.
        PSDDuration (1, 1) duration = hours(1)
    end

    methods

        function this = Frequency(results, options)

            arguments
                results
                options.?mag.graphics.view.Frequency
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            [primarySensor, secondarySensor] = this.getSensorNames();

            primary = this.Results.Primary;
            secondary = this.Results.Secondary;

            if ismissing(this.PSDStart) || ~isbetween(this.PSDStart, primary.Time(1), primary.Time(end))
                psdStart = primary.Time(1);
            else
                psdStart = this.PSDStart;
            end

            if (this.PSDDuration > (primary.Time(end) - psdStart))
                psdDuration = primary.Time(end) - psdStart;
            else
                psdDuration = this.PSDDuration;
            end

            psdPrimary = primary.computePSD(Start = psdStart, Duration = psdDuration);
            psdSecondary = secondary.computePSD(Start = psdStart, Duration = psdDuration);

            yLine = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10pT");

            this.Figures = this.Factory.assemble( ...
                psdPrimary, mag.graphics.style.Default(Title = compose("%s PSD", primarySensor) , XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], Layout = [2, 3], Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine]), ...
                psdSecondary, mag.graphics.style.Default(Title = compose("%s PSD", secondarySensor), XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", YAxisLocation = "right", Legend = ["x", "y", "z"], Layout = [2, 3], Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine]), ...
                primary, ...
                [mag.graphics.style.Colormap(Title = compose("%s B_x Spectrogram", primarySensor), YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [1, 2], Charts = mag.graphics.chart.Spectrogram(YVariables = "X")), ...
                mag.graphics.style.Colormap(Title = compose("%s B_y Spectrogram", primarySensor), YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [1, 2], Charts = mag.graphics.chart.Spectrogram(YVariables = "Y")), ...
                mag.graphics.style.Colormap(Title = compose("%s B_z Spectrogram", primarySensor), YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [1, 2], Charts = mag.graphics.chart.Spectrogram(YVariables = "Z"))], ...
                secondary, ...
                [mag.graphics.style.Colormap(Title = compose("%s B_x Spectrogram", secondarySensor), YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [1, 2], Charts = mag.graphics.chart.Spectrogram(YVariables = "X")), ...
                mag.graphics.style.Colormap(Title = compose("%s B_y Spectrogram", secondarySensor), YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [1, 2], Charts = mag.graphics.chart.Spectrogram(YVariables = "Y")), ...
                mag.graphics.style.Colormap(Title = compose("%s B_z Spectrogram", secondarySensor), YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Layout = [1, 2], Charts = mag.graphics.chart.Spectrogram(YVariables = "Z"))], ...
                Title = this.getFigureTitle(primary, secondary, psdStart, psdDuration), ...
                Name = this.getFigureName(primary, secondary, psdStart), ...
                Arrangement = [4, 6], ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function value = getFigureTitle(this, primary, secondary, psdStart, psdDuration)
            value = compose("Start: %s - Duration: %s - (%d, %d)", this.date2str(psdStart), psdDuration, primary.MetaData.getDisplay("DataFrequency"), secondary.MetaData.getDisplay("DataFrequency"));
        end

        function value = getFigureName(this, primary, secondary, psdStart)
            value = compose("%s (%d, %d) Frequency (%s)", primary.MetaData.getDisplay("Mode"), primary.MetaData.getDisplay("DataFrequency"), secondary.MetaData.getDisplay("DataFrequency"), this.date2str(psdStart));
        end
    end
end
