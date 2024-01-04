classdef Filter < mag.process.Step
% FILTER Remove some data points at the beginning of the sample.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties (Constant, Access = private)
        % VECTORSPERPACKET Number of expected vectors in each packet.
        VectorsPerPacket (1, :) double = [1 * 8, 2 * 8, 4 * 8, 8 * 2, 64 * 2, 128 * 2]
    end

    properties
        % ONRANGECHANGE How long to remove when range changes.
        OnRangeChange (1, 2) duration
        % ONMODECHANGE How many vectors to remove when mode changes.
        OnModeChange (1, 2) double
    end

    methods

        function this = Filter(options)

            arguments
                options.?mag.process.Filter
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Filter Out Data";
        end

        function value = get.Description(~)
            value = "Filter out data after mode and range change events.";
        end

        function value = get.DetailedDescription(this)

            value = this.Description + " After said events, onboard filtering " + ...
                "needs time to adjust, thus some data points are dropped for display purposes. " + ...
                "For range changes, " + string(this.OnRangeChange(1)) + "-worth before and " + string(this.OnRangeChange(2)) + ...
                "-worth after are dropped, and for mode changes, " + string(this.OnModeChange(1)) + " vector before and " + ...
                string(this.OnModeChange(2)) + " after are dropped.";
        end

        function data = apply(this, data, ~)

            arguments
                this
                data timetable
                ~
            end

            [startTime, endTime] = bounds(data.t);

            events = data.Properties.Events;
            events = events(timerange(startTime, endTime, "closed"), :);

            locMode = [true; diff(events.DataFrequency) ~= 0];
            locRange = [true; diff(events.Range) ~= 0];

            % Filter data points at mode changes.
            for t = events.Time(locMode)'

                idxTime = find(events.Time == t);
                data(idxTime + (this.OnModeChange(1):this.OnModeChange(2)), :) = [];
            end

            % Filter duration at range changes.
            for t = events.Time(locRange)'
                data(timerange(t + this.OnRangeChange(1), t + this.OnRangeChange(2), "closed"), :) = [];
            end

            % Filter out between config and ramp mode.
            % Ramp mode is surrounded by two config modes. Remove data from
            % the first to the last config.
            locConfig = contains(events.Label, "Config");
            idxConfig = find(locConfig);

            if (nnz(locConfig) == 2) && any(contains([events.Label(idxConfig(1):idxConfig(end))], "Ramp"))
                data(timerange(events.Time(idxConfig(1)), events.Time(idxConfig(end)), "closed"), :) = [];
            end

            % Make sure no sliced packets remain.
            % data = this.removeSlicedSequences(data);
        end
    end

    methods (Static, Access = private)

        function data = removeSlicedSequences(data)

            events = data.Properties.Events;
            modeEvents = events(~ismissing(events.Duration), :);

            locCombine = ([NaN; diff(modeEvents.DataFrequency)] == 0);
            modeEvents(locCombine, :) = [];

            for e = 1:height(modeEvents)

                if e == height(modeEvents)
                    endTime = data.t(end);
                else
                    endTime = modeEvents.Time(e + 1);
                end

                locTime = isbetween(data.t, modeEvents.Time(e), endTime, "closedleft");
                vectorsPerPacket = modeEvents.DataFrequency(e) * modeEvents.PacketFrequency(e);

                sequence = mag.process.Step.correctSequence(data.sequence);
                [~, idxSequence] = unique(sequence);

                idxPeriod = idxSequence(locTime(idxSequence));
                locSequence = diff(idxPeriod) ~= vectorsPerPacket;

                data(ismember(sequence, sequence(idxPeriod(locSequence))), :) = [];
            end
        end
    end
end
