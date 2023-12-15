classdef (Sealed) Instrument < handle & matlab.mixin.Copyable & mag.mixin.SetGet
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
                primaryFilter (1, 1) {mustBeA(primaryFilter, ["timerange", "duration"])}
                secondaryFilter (1, 1) {mustBeA(secondaryFilter, ["timerange", "duration"])} = primaryFilter
            end

            if isa(primaryFilter, "timerange")
                [primaryPeriod, secondaryPeriod] = deal(primaryFilter, secondaryFilter);
            elseif isa(primaryFilter, "duration")

                primaryPeriod = timerange(this.Primary.Time(1) + primaryFilter, this.Primary.Time(end), "openleft");
                secondaryPeriod = timerange(this.Secondary.Time(1) + secondaryFilter, this.Secondary.Time(end), "openleft");
            end

            this.Primary.Data = this.Primary.Data(primaryPeriod, :);
            this.Primary.Data.Properties.Events = this.Primary.Data.Properties.Events(primaryPeriod, :);

            this.Secondary.Data = this.Secondary.Data(secondaryPeriod, :);
            this.Secondary.Data.Properties.Events = this.Secondary.Data.Properties.Events(secondaryPeriod, :);
        end

        function cropDataBasedOnScience(this)
        % CROPDATABASEDONSCIENCE Crop meta data, events and HK based on
        % science timestamps.

            timeRange = this.TimeRange;

            % Filter events.
            this.Events = this.Events(isbetween([this.Events.CommandTimestamp], timeRange(1), timeRange(2), "closed"));

            % Filter HK.
            for i = 1:numel(this.HK)
                this.HK(i).Data = this.HK(i).Data(timerange(timeRange(1), timeRange(2), "closed"), :);
            end

            % Adjust meta data.
            this.MetaData.Timestamp = timeRange(1);
            this.Primary.MetaData.Timestamp = timeRange(1);
            this.Secondary.MetaData.Timestamp = timeRange(1);
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
    end
end
