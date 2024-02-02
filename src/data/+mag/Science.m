classdef (Sealed) Science < mag.TimeSeries & matlab.mixin.CustomDisplay
% SCIENCE Class containing MAG science data.

    properties (Dependent)
        % X x-axis component of the magnetic field.
        X (:, 1) double
        % Y y-axis component of the magnetic field.
        Y (:, 1) double
        % Z z-axis component of the magnetic field.
        Z (:, 1) double
        % XYZ x-, y- and z-axis components of the magnetic field.
        XYZ (:, 3) double
        % B Magnitude of the magnetic field.
        B (:, 1) double
        % DX x-axis derivative of the magnetic field.
        dX (:, 1) double
        % DY y-axis derivative of the magnetic field.
        dY (:, 1) double
        % DZ z-axis derivative of the magnetic field.
        dZ (:, 1) double
        % RANGE Range values of sensor.
        Range (:, 1) uint8
        % SEQUENCE Sequence number of vectors.
        Sequence (:, 1) uint16
        % EVENTS Events detected.
        Events eventtable
    end

    methods

        function this = Science(scienceData, metaData)

            arguments
                scienceData timetable
                metaData (1, 1) mag.meta.Science
            end

            this.Data = scienceData;
            this.MetaData = metaData;
        end

        function x = get.X(this)
            x = this.Data.x;
        end

        function y = get.Y(this)
            y = this.Data.y;
        end

        function z = get.Z(this)
            z = this.Data.z;
        end

        function xyz = get.XYZ(this)
            xyz = this.Data{:, ["x", "y", "z"]};
        end

        function b = get.B(this)
            b = vecnorm(this.XYZ, 2, 2);
        end

        function dx = get.dX(this)
            dx = this.computeDerivative(this.X);
        end

        function dy = get.dY(this)
            dy = this.computeDerivative(this.Y);
        end

        function dz = get.dZ(this)
            dz = this.computeDerivative(this.Z);
        end

        function range = get.Range(this)
            range = this.Data.range;
        end

        function sequence = get.Sequence(this)
            sequence = this.Data.sequence;
        end

        function events = get.Events(this)
            events = this.Data.Properties.Events;
        end

        function crop(this, timeFilter)

            arguments
                this (1, 1) mag.Science
                timeFilter (1, 1) {mustBeA(timeFilter, ["duration", "timerange", "withtol"])}
            end

            if isa(timeFilter, "duration")
                timePeriod = timerange(this.Time(1) + timeFilter, this.Time(end), "closed");
            elseif isa(timeFilter, "timerange") || isa(timeFilter, "withtol")
                timePeriod = timeFilter;
            end

            this.Data = this.Data(timePeriod, :);

            if ~isempty(this.Data.Properties.Events)
                this.Data.Properties.Events = this.Data.Properties.Events(timePeriod, :);
            end

            if isempty(this.Time)
                this.MetaData.Timestamp = NaT(TimeZone = mag.process.DateTime.TimeZone);
            else
                this.MetaData.Timestamp = this.Time(1);
            end
        end

        function resample(this, targetFrequency)

            arguments
                this (1, 1) mag.Science
                targetFrequency (1, 1) double
            end

            actualFrequency = 1 / seconds(mode(this.dT));
            
            if actualFrequency > targetFrequency

                numerator = 1;
                denominator = actualFrequency / targetFrequency;
            else

                numerator = targetFrequency / actualFrequency;
                denominator = 1;
            end

            if (round(numerator) ~= numerator) || (round(denominator) ~= denominator)
                error("Calculated numerator (%.3f) and denominator (%.3f) must be integers.", numerator, denominator);
            end

            xyz = resample(this.Data(:, ["x", "y", "z"]), numerator, denominator);
            xyz = xyz(timerange(this.Time(1), this.Time(end), "closed"), :);

            resampledData = retime(this.Data, xyz.Time, "nearest");
            resampledData(:, ["x", "y", "z"]) = xyz;

            this.Data = resampledData;
            this.MetaData.DataFrequency = targetFrequency;
        end

        function downsample(this, targetFrequency)

            arguments
                this (1, 1) mag.Science
                targetFrequency (1, 1) double
            end

            actualFrequency = 1 / seconds(mode(this.dT));
            decimationFactor = actualFrequency / targetFrequency;

            if round(decimationFactor) ~= decimationFactor
                error("Calculated decimation factor (%.3f) must be an integer.", decimationFactor);
            end

            a = ones(1, decimationFactor) / decimationFactor;
            b = conv(a, a);

            this.filter(b);

            this.Data = downsample(this.Data, decimationFactor);
            this.MetaData.DataFrequency = targetFrequency;
        end

        function filter(this, numeratorOrFilter, denominator)
        % FILTER Filter science data with specified numerator/denominator
        % pair, or filter object.

            arguments
                this (1, 1) mag.Science
                numeratorOrFilter (1, :) {mustBeA(numeratorOrFilter, ["double", "digitalFilter"])}
                denominator (1, :) double = double.empty()
            end

            if isa(numeratorOrFilter, "digitalFilter")
                arguments = {numeratorOrFilter};
            elseif isempty(denominator)
                arguments = {numeratorOrFilter, 1};
            else
                arguments = {numeratorOrFilter, denominator};
            end

            this.Data{:, ["x", "y", "z"]} = filter(arguments{:}, this.XYZ);

            if isa(numeratorOrFilter, "digitalFilter")
                numCoefficients = numel(numeratorOrFilter.Coefficients);
            else
                numCoefficients = numel(numeratorOrFilter);
            end

            if numCoefficients > height(this.Data)
                numCoefficients = height(this.Data);
            end

            this.Data{1:numCoefficients, ["x", "y", "z"]} = missing();
        end

        function replace(this, timeFilter, filler)
        % REPLACE Replace length of data specified by time filter with
        % filler variable.

            arguments
                this (1, 1) mag.Science
                timeFilter (1, 1) {mustBeA(timeFilter, ["duration", "timerange", "withtol"])}
                filler (1, 1) double = missing()
            end

            if isa(timeFilter, "duration")
                timePeriod = timerange(this.Time(1), this.Time(1) + timeFilter, "closed");
            elseif isa(timeFilter, "timerange") || isa(timeFilter, "withtol")
                timePeriod = timeFilter;
            end

            this.Data{timePeriod, ["x", "y", "z"]} = filler;
        end

        function data = computePSD(this, options)
        % COMPUTEPSD Compute the power spectral density of the magnetic
        % field measurements.

            arguments (Input)
                this (1, 1) mag.Science
                options.Start datetime {mustBeScalarOrEmpty} = datetime.empty()
                options.Duration (1, 1) duration = hours(1)
                options.FFTType (1, 1) double {mustBeGreaterThanOrEqual(options.FFTType, 1), mustBeLessThanOrEqual(options.FFTType, 3)} = 2
                options.NW (1, 1) double = 7/2
            end

            arguments (Output)
                data (1, 1) mag.PSD
            end

            % Filter out data.
            if isempty(options.Start)

                t = this.Time;
                locFilter = true(size(this.Data, 1), 1);
            else

                t = (this.Time - options.Start);

                locFilter = t > 0;

                if (options.Duration ~= 0)
                    locFilter = locFilter & (t < options.Duration);
                end
            end

            % Compute PSD.
            dt = seconds(median(diff(t(locFilter))));

            [psd, f] = psdtsh(this.XYZ(locFilter, :), dt, options.FFTType, options.NW);
            psd = psd .^ 0.5;

            data = mag.PSD(table(f, psd(:, 1), psd(:, 2), psd(:, 3), VariableNames = ["f", "x", "y", "z"]));
        end
    end

    methods (Access = protected)

        function header = getHeader(this)

            if isscalar(this)

                if ~isempty(this.MetaData) && ~isempty(this.MetaData.Sensor) && ~isempty(this.MetaData.Model)
                    tag = char(compose(" from %s (%s) in %s (%d)", this.MetaData.Sensor, this.MetaData.Model, this.MetaData.Mode, this.MetaData.DataFrequency));
                elseif ~isempty(this.MetaData) && ~isempty(this.MetaData.Sensor)
                    tag = char(compose(" from %s in %s (%d)", this.MetaData.Sensor, this.MetaData.Mode, this.MetaData.DataFrequency));
                elseif ~isempty(this.MetaData)
                    tag = char(compose(" in %s (%d)", this.MetaData.Mode, this.MetaData.DataFrequency));
                else
                    tag = char.empty();
                end

                className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
                header = ['  ', className, tag, ' with properties:'];
            else
                header = getHeader@matlab.mixin.CustomDisplay(this);
            end
        end
    end
end
