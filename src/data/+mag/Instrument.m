classdef (Sealed) Instrument < handle & matlab.mixin.Copyable & matlab.mixin.CustomDisplay & mag.mixin.SetGet
% INSTRUMENT Class containing MAG instrument data.

    properties
        % EVENTS Event data.
        Events mag.event.Event {mustBeVector(Events, "allow-all-empties")}
        % METADATA Meta data.
        MetaData mag.meta.Instrument {mustBeScalarOrEmpty}
        % PRIMARY Primary science data.
        Primary mag.Science {mustBeScalarOrEmpty}
        % SECONDARY Secondary science data.
        Secondary mag.Science {mustBeScalarOrEmpty}
        % HK Housekeeping data.
        HK mag.HK {mustBeVector(HK, "allow-all-empties")}
    end

    properties (Dependent, SetAccess = private)
        % HASDATA Logical denoting whether instrument has any data.
        HasData (1, 1) logical
        % HASMETADATA Logical denoting whether instrument has meta data.
        HasMetaData (1, 1) logical
        % HASSCIENCE Logical denoting whether instrument has science data.
        HasScience (1, 1) logical
        % HASHK Logical denoting whether instrument has HK data.
        HasHK (1, 1) logical
        % TIMERANGE Time range covered by science data.
        TimeRange (1, 2) datetime
    end

    methods

        function this = Instrument(options)

            arguments
                options.?mag.Instrument
            end

            this.assignProperties(options);
        end

        function value = get.HasData(this)
            value = this.HasMetaData || this.HasScience || this.HasHK;
        end

        function value = get.HasMetaData(this)
            value = ~isempty(this.MetaData);
        end

        function value = get.HasScience(this)
            value = ~isempty(this.Primary) && ~isempty(this.Secondary);
        end

        function value = get.HasHK(this)
            value = ~isempty(this.HK);
        end

        function value = get.TimeRange(this)

            if this.HasScience

                value = [min([this.Primary.Time(1), this.Secondary.Time(1)]), ...
                    max([this.Primary.Time(end), this.Secondary.Time(end)])];
            else
                value = [NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC")];
            end
        end

        function sensor = getSensor(this, primaryOrSecondary)
        % GETSENSOR Return name of primary or secondary sensor.

            arguments (Input)
                this
                primaryOrSecondary (1, 1) string {mustBeMember(primaryOrSecondary, ["Primary", "Secondary"])} = "Primary"
            end

            arguments (Output)
                sensor (1, 1) mag.meta.Sensor
            end

            primarySensor = this.MetaData.Primary;
            supportedSensors = enumeration("mag.meta.Sensor");

            switch primaryOrSecondary
                case "Primary"
                    locSelected = supportedSensors == primarySensor;
                case "Secondary"
                    locSelected = supportedSensors ~= primarySensor;
            end

            sensor = supportedSensors(locSelected);
        end

        function crop(this, primaryFilter, secondaryFilter)
        % CROP Crop data based on selected filters for primary and
        % secondary science.

            arguments
                this
                primaryFilter
                secondaryFilter = primaryFilter
            end

            this.cropScience(primaryFilter, secondaryFilter);
            this.cropDataBasedOnScience();
        end

        function cropScience(this, primaryFilter, secondaryFilter)
        % CROPSCIENCE Crop only science data based on selected time
        % filters.

            arguments
                this
                primaryFilter (1, 1) {mustBeA(primaryFilter, ["duration", "timerange", "withtol"])}
                secondaryFilter (1, 1) {mustBeA(secondaryFilter, ["duration", "timerange", "withtol"])} = primaryFilter
            end

            if isa(primaryFilter, "duration")

                primaryPeriod = timerange(this.Primary.Time(1) + primaryFilter, this.Primary.Time(end), "openleft");
                secondaryPeriod = timerange(this.Secondary.Time(1) + secondaryFilter, this.Secondary.Time(end), "openleft");
            elseif isa(primaryFilter, "timerange") || isa(primaryFilter, "withtol")
                [primaryPeriod, secondaryPeriod] = deal(primaryFilter, secondaryFilter);
            end

            this.Primary.Data = this.Primary.Data(primaryPeriod, :);

            if ~isempty(this.Primary.Data.Properties.Events)
                this.Primary.Data.Properties.Events = this.Primary.Data.Properties.Events(primaryPeriod, :);
            end

            this.Secondary.Data = this.Secondary.Data(secondaryPeriod, :);

            if ~isempty(this.Secondary.Data.Properties.Events)
                this.Secondary.Data.Properties.Events = this.Secondary.Data.Properties.Events(secondaryPeriod, :);
            end
        end

        function cropDataBasedOnScience(this)
        % CROPDATABASEDONSCIENCE Crop meta data, events and HK based on
        % science timestamps.

            timeRange = this.TimeRange;

            % Filter events.
            if ~isempty(this.Events)
                this.Events = this.Events(isbetween([this.Events.CommandTimestamp], timeRange(1), timeRange(2), "closed"));
            end

            % Filter HK.
            for i = 1:numel(this.HK)
                this.HK(i).Data = this.HK(i).Data(timerange(timeRange(1), timeRange(2), "closed"), :);
            end

            % Adjust meta data.
            this.MetaData.Timestamp = timeRange(1);
            this.Primary.MetaData.Timestamp = timeRange(1);
            this.Secondary.MetaData.Timestamp = timeRange(1);
        end

        function resample(this, targetFrequency)
        % RESAMPLE Resample primary and secondary data to the specified
        % frequency.

            arguments
                this
                targetFrequency (1, 1) double
            end

            for s = ["Primary", "Secondary"]

                originalData = this.(s).Data;

                xyz = resample(originalData(:, ["x", "y", "z"]), targetFrequency);

                resampledData = retime(originalData, xyz.Time, "nearest");
                resampledData(:, ["x", "y", "z"]) = xyz;

                this.(s).Data = resampledData;
                this.(s).MetaData.DataFrequency = targetFrequency;
            end
        end

        function downsample(this, targetFrequency)
        % DOWNSAMPLE Downsample primary and secondary data to the specified
        % frequency.

            arguments
                this
                targetFrequency (1, 1) double
            end

            for s = ["Primary", "Secondary"]

                actualFrequency = 1 / mode(seconds(diff(this.(s).Time)));
                decimationFactor = actualFrequency / targetFrequency;

                if round(decimationFactor) ~= decimationFactor
                    error("Calculated decimation factor (%.3f) must be an integer.", decimationFactor);
                end

                a = ones(1, decimationFactor) / decimationFactor;
                b = conv(a, a);

                data = this.(s).Data;
                data{:, ["x", "y", "z"]} = filter(b, 1, data{:, ["x", "y", "z"]});

                data(1:numel(b), :) = [];

                this.(s).Data = downsample(data, decimationFactor);
                this.(s).MetaData.DataFrequency = targetFrequency;
            end
        end
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@matlab.mixin.Copyable(this);

            copiedThis.MetaData = copy(this.MetaData);
            copiedThis.Primary = copy(this.Primary);
            copiedThis.Secondary = copy(this.Secondary);
            copiedThis.HK = copy(this.HK);
        end

        function header = getHeader(this)

            if isscalar(this)

                if this.HasScience && this.HasMetaData && ...
                        ~isempty(this.Primary.MetaData) && ~ismissing(this.Primary.MetaData.DataFrequency) && ~isequal(this.Primary.MetaData.Mode, "Hybrid") && ...
                        ~isempty(this.Secondary.MetaData) && ~ismissing(this.Secondary.MetaData.DataFrequency) && ~isequal(this.Secondary.MetaData.Mode, "Hybrid")

                    tag = char(compose(" in %s (%d, %d)", this.Primary.MetaData.Mode, this.Primary.MetaData.DataFrequency, this.Secondary.MetaData.DataFrequency));
                else
                    tag = char.empty();
                end

                className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
                header = ['  ', className, tag, ' with properties:'];
            else
                header = getHeader@matlab.mixin.CustomDisplay(this);
            end
        end

        function groups = getPropertyGroups(this)

            if isscalar(this)

                propertyList = ["HasData", "HasMetaData", "HasScience", "HasHK", "TimeRange", ...
                    "Primary", "Secondary", ...
                    "MetaData", "Events", "HK"];
                groups = matlab.mixin.util.PropertyGroup(propertyList, "");
            else
                groups = getPropertyGroups@matlab.mixin.CustomDisplay(this);
            end
        end
    end
end
