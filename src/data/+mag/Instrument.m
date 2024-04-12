classdef (Sealed) Instrument < handle & matlab.mixin.Copyable & matlab.mixin.CustomDisplay & mag.mixin.SetGet
% INSTRUMENT Class containing MAG instrument data.

    properties
        % EVENTS Event data.
        Events (1, :) mag.event.Event
        % METADATA Meta data.
        MetaData mag.meta.Instrument {mustBeScalarOrEmpty}
        % SCIENCE Science data.
        Science (1, :) mag.Science
        % IALIRT I-ALiRT data.
        IALiRT mag.IALiRT {mustBeScalarOrEmpty}
        % HK Housekeeping data.
        HK (1, :) mag.HK
    end

    properties (Dependent, SetAccess = private)
        % HASDATA Logical denoting whether instrument has any data.
        HasData (1, 1) logical
        % HASMETADATA Logical denoting whether instrument has meta data.
        HasMetaData (1, 1) logical
        % HASSCIENCE Logical denoting whether instrument has science data.
        HasScience (1, 1) logical
        % HASIALIRT Logical denoting whether instrument has I-ALiRT data.
        HasIALiRT (1, 1) logical
        % HASHK Logical denoting whether instrument has HK data.
        HasHK (1, 1) logical
        % TIMERANGE Time range covered by science data.
        TimeRange (1, 2) datetime
        % PRIMARY Primary science data.
        Primary mag.Science {mustBeScalarOrEmpty}
        % SECONDARY Secondary science data.
        Secondary mag.Science {mustBeScalarOrEmpty}
    end

    methods

        function this = Instrument(options)

            arguments
                options.?mag.Instrument
            end

            this.assignProperties(options);
        end

        function value = get.HasData(this)
            value = this.HasMetaData || this.HasScience || this.HasIALiRT || this.HasHK;
        end

        function value = get.HasMetaData(this)
            value = ~isempty(this.MetaData);
        end

        function value = get.HasScience(this)
            value = ~isempty(this.Science) && all([this.Science.HasData]);
        end

        function value = get.HasIALiRT(this)
            value = ~isempty(this.IALiRT);
        end

        function value = get.HasHK(this)
            value = ~isempty(this.HK) && this.HK.HasData;
        end

        function value = get.TimeRange(this)

            if this.HasScience

                firstTimes = arrayfun(@(x) x.Time(1), this.Science, UniformOutput = true);
                lastTimes = arrayfun(@(x) x.Time(end), this.Science, UniformOutput = true);

                value = [min(firstTimes), max(lastTimes)];
            else
                value = [NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC")];
            end
        end

        function primary = get.Primary(this)

            sensor = this.getSensor("Primary");

            if isempty(sensor) || isempty(this.Science)

                primary = mag.Science.empty();
                return;
            end

            metaData = [this.Science.MetaData];
            locPrimary = [metaData.Sensor] == sensor;

            primary = this.Science(locPrimary);
        end

        function secondary = get.Secondary(this)

            sensor = this.getSensor("Secondary");

            if isempty(sensor) || isempty(this.Science)

                secondary = mag.Science.empty();
                return;
            end

            metaData = [this.Science.MetaData];
            locSecondary = [metaData.Sensor] == sensor;

            secondary = this.Science(locSecondary);
        end

        function sensor = getSensor(this, primaryOrSecondary)
        % GETSENSOR Return name of primary or secondary sensor.

            arguments (Input)
                this (1, 1) mag.Instrument
                primaryOrSecondary (1, 1) string {mustBeMember(primaryOrSecondary, ["Primary", "Secondary"])} = "Primary"
            end

            arguments (Output)
                sensor mag.meta.Sensor {mustBeScalarOrEmpty}
            end

            if isempty(this.MetaData)

                sensor = mag.meta.Sensor.empty();
                return;
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

        function fillWarmUp(this, timePeriod, filler)
        % FILLWARMUP Replace beginning of science mode with filler
        % variable.

            arguments
                this (1, 1) mag.Instrument
                timePeriod (1, 1) duration = minutes(1)
                filler (1, 1) double = missing()
            end

            for s = this.Science
                s.replace(timePeriod, filler);
            end
        end

        function crop(this, primaryFilter, secondaryFilter)
        % CROP Crop data based on selected filters for primary and
        % secondary science.

            arguments
                this (1, 1) mag.Instrument
                primaryFilter
                secondaryFilter = primaryFilter
            end

            this.cropScience(primaryFilter, secondaryFilter);
            this.cropToMatch();
        end

        function cropScience(this, primaryFilter, secondaryFilter)
        % CROPSCIENCE Crop only science data based on selected time
        % filters.

            arguments
                this (1, 1) mag.Instrument
                primaryFilter (1, 1) {mustBeA(primaryFilter, ["duration", "timerange", "withtol"])}
                secondaryFilter (1, 1) {mustBeA(secondaryFilter, ["duration", "timerange", "withtol"])} = primaryFilter
            end

            % Filter science.
            this.Primary.crop(primaryFilter);
            this.Secondary.crop(secondaryFilter);

            % Filter I-ALiRT.
            if this.HasIALiRT
                this.IALiRT.crop(primaryFilter, secondaryFilter);
            end
        end

        function cropToMatch(this, startTime, endTime)
        % CROPTOMATCH Crop meta data, events and HK based on science
        % timestamps or specified timestamps.

            arguments
                this (1, 1) mag.Instrument
                startTime (1, 1) datetime = this.TimeRange(1)
                endTime (1, 1) datetime = this.TimeRange(2)
            end

            % Filter events.
            if ~isempty(this.Events)
                this.Events = this.Events(isbetween([this.Events.CommandTimestamp], startTime, endTime, "closed"));
            end

            % Filter HK.
            this.HK.crop(timerange(startTime, endTime, "closed"));

            % Adjust meta data.
            this.MetaData.Timestamp = startTime;
        end

        function resample(this, targetFrequency)
        % RESAMPLE Resample science and HK data to the specified frequency.

            arguments
                this (1, 1) mag.Instrument
                targetFrequency (1, 1) double
            end

            for s = this.Science
                s.resample(targetFrequency);
            end

            for hk = this.HK
                hk.resample(targetFrequency);
            end
        end

        function downsample(this, targetFrequency)
        % DOWNSAMPLE Downsample science and HK data to the specified
        % frequency.

            arguments
                this (1, 1) mag.Instrument
                targetFrequency (1, 1) double
            end

            for s = this.Science
                s.downsample(targetFrequency);
            end

            for hk = this.HK
                hk.downsample(targetFrequency);
            end
        end
    end

    methods (Hidden, Sealed, Static)

        function loadedObject = loadobj(object)
        % LOADOBJ Override default loading from MAT file.

            if isa(object, "mag.Instrument")
                loadedObject = object;
            else

                if ~isfield(object, "Science")

                    science = [object.Primary, object.Secondary];
                    object = rmfield(object, ["Primary", "Secondary"]);

                    args = namedargs2cell(object);
                    loadedObject = mag.Instrument(args{:}, Science = science);
                end
            end
        end
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@matlab.mixin.Copyable(this);

            copiedThis.MetaData = copy(this.MetaData);
            copiedThis.Science = copy(this.Science);
            copiedThis.IALiRT = copy(this.IALiRT);
            copiedThis.HK = copy(this.HK);
        end

        function header = getHeader(this)

            if isscalar(this) && this.HasScience && this.HasMetaData && ~isempty(this.Primary.MetaData) && ~isempty(this.Secondary.MetaData)

                className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
                tag = char(compose(" in %s (%d, %d)", this.Primary.MetaData.Mode, this.Primary.MetaData.DataFrequency, this.Secondary.MetaData.DataFrequency));

                header = ['  ', className, tag, ' with properties:'];
            else
                header = getHeader@matlab.mixin.CustomDisplay(this);
            end
        end

        function groups = getPropertyGroups(this)

            if isscalar(this)

                propertyList = ["HasData", "HasMetaData", "HasScience", "HasHK", "TimeRange", ...
                    "Primary", "Secondary", "Science", "IALiRT", ...
                    "MetaData", "Events", "HK"];
                groups = matlab.mixin.util.PropertyGroup(propertyList, "");
            else
                groups = getPropertyGroups@matlab.mixin.CustomDisplay(this);
            end
        end
    end
end
