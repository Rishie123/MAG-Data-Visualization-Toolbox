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

            % Field and spectrogram.
            secondaryCharts = this.getFrequencyCharts(secondarySensor);
            [secondaryCharts(1:2:end).YAxisLocation] = deal("right");

            this.Figures(1) = this.Factory.assemble( ...
                primary, ...
                this.getFrequencyCharts(primarySensor), ...
                secondary, ...
                secondaryCharts, ...
                Title = this.getFrequencyFigureTitle(primary, secondary), ...
                Name = this.getFrequencyFigureName(primary, secondary), ...
                Arrangement = [6, 2], ...
                LinkXAxes = true, ...
                TileIndexing = "columnmajor", ...
                WindowState = "maximized");

            % PSD and spectrogram.
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

            this.Figures(2) = this.Factory.assemble( ...
                psdPrimary, mag.graphics.style.Default(Title = compose("%s PSD", primarySensor), XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine]), ...
                psdSecondary, mag.graphics.style.Default(Title = compose("%s PSD", secondarySensor), XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", YAxisLocation = "right", Legend = ["x", "y", "z"], Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine]), ...
                Title = this.getPSDFigureTitle(primary, secondary, psdStart, psdDuration), ...
                Name = this.getPSDFigureName(primary, secondary, psdStart), ...
                Arrangement = [2, 1], ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function charts = getFrequencyCharts(this, name)

            charts = [ ...
                mag.graphics.style.Default(Title = compose("%s x", name), YLabel = "[nT]", Charts = mag.graphics.chart.Plot(YVariables = "X")), ...
                mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Charts = mag.graphics.chart.Spectrogram(YVariables = "X")), ...
                mag.graphics.style.Default(Title = compose("%s y", name), YLabel = "[nT]", Charts = mag.graphics.chart.Plot(YVariables = "Y")), ...
                mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Charts = mag.graphics.chart.Spectrogram(YVariables = "Y")), ...
                mag.graphics.style.Default(Title = compose("%s z", name), YLabel = "[nT]", Charts = mag.graphics.chart.Plot(YVariables = "Z")), ...
                mag.graphics.style.Colormap(YLabel = this.FLabel, CLabel = this.PLabel, YLimits = "tight", Charts = mag.graphics.chart.Spectrogram(YVariables = "Z"))];
        end

        function value = getFrequencyFigureTitle(~, primary, secondary)
            value = compose("%s (%d, %d)", primary.MetaData.getDisplay("Mode"), primary.MetaData.getDisplay("DataFrequency"), secondary.MetaData.getDisplay("DataFrequency"));
        end

        function value = getFrequencyFigureName(this, primary, secondary)
            value = this.getFrequencyFigureTitle(primary, secondary) + compose(" Frequency (%s)", this.date2str(primary.MetaData.Timestamp));
        end

        function value = getPSDFigureTitle(this, primary, secondary, psdStart, psdDuration)
            value = compose("Start: %s - Duration: %s - (%d, %d)", this.date2str(psdStart), psdDuration, primary.MetaData.getDisplay("DataFrequency"), secondary.MetaData.getDisplay("DataFrequency"));
        end

        function value = getPSDFigureName(this, primary, secondary, psdStart)
            value = compose("%s (%d, %d) PSD (%s)", primary.MetaData.getDisplay("Mode"), primary.MetaData.getDisplay("DataFrequency"), secondary.MetaData.getDisplay("DataFrequency"), this.date2str(psdStart));
        end
    end
end
