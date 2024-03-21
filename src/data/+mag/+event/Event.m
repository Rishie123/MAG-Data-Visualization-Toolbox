classdef (Abstract) Event < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% EVENT Interface for MAG events.

    properties (Constant)
        % COMMONFORMAT Common format for event details.
        CommonFormat (1, 1) string = "(?:OPCODE=)?(?<opcode>\d+), (?:PUS_SECHDRFLAG=)?(?<header>\d+), (?:PUS_VERSION=)?(?<version>\d+), (?:PUS_ACK=)?(?<ack>\d+), (?:PUS_STYPE=)?(?<type>\d+), (?:PUS_SSUBTYPE=)?(?<subtype>\d+)"
    end

    properties (Abstract, Constant)
        % SPECIFICFORMAT Specific format for event details.
        SpecificFormat (1, 1) string
    end

    properties
        % COMMANDTIMESTAMP Timestamp of command.
        CommandTimestamp (1, 1) datetime = NaT(TimeZone = "UTC")
        % ACKNOWLEDGETIMESTAMP Timestamp of acknowledge.
        AcknowledgeTimestamp (1, 1) datetime = NaT(TimeZone = "UTC")
        % COMPLETETIMESTAMP Timestamp of completion.
        CompleteTimestamp (1, 1) datetime = NaT(TimeZone = "UTC")
        % TYPE Packet type.
        Type (1, 1) double
        % SUBTYPE Packet subtype.
        SubType (1, 1) double
    end

    methods (Sealed)

        function sortedThis = sort(this, varargin)
        % SORT Override default sorting algorithm.

            [~, idxSort] = sort([this.CompleteTimestamp], varargin{:});
            sortedThis = this(idxSort);
        end
    end

    methods (Hidden, Sealed)

        function timetableThis = timetable(this)
        % TIMETABLE Convert events to timetable.

            emptyTime = datetime.empty();
            emptyTime.TimeZone = "UTC";

            timetableThis = struct2table(struct(Time = emptyTime, ...
                Mode = string.empty(0, 1), ...
                PrimaryNormalRate = double.empty(0, 1), ...
                SecondaryNormalRate = double.empty(0, 1), ...
                PacketNormalFrequency = double.empty(0, 1), ...
                PrimaryBurstRate = double.empty(0, 1), ...
                SecondaryBurstRate = double.empty(0, 1), ...
                PacketBurstFrequency = double.empty(0, 1), ...
                Duration = double.empty(0, 1), ...
                Range = double.empty(0, 1), ...
                Sensor = string.empty(0, 1), ...
                Label = string.empty(0, 1)));
            timetableThis = table2timetable(timetableThis, RowTimes = "Time");

            for t = 1:numel(this)

                tt = this(t).convertToTimeTable();
                timetableThis = outerjoin(timetableThis, tt, MergeKeys = true, Keys = ["Time", intersect(timetableThis.Properties.VariableNames, tt.Properties.VariableNames)]);
            end

            timetableThis = sortrows(timetableThis);

            fillVariables = intersect(["Mode", "PrimaryNormalRate", "SecondaryNormalRate", "PacketNormalFrequency", "PrimaryBurstRate", "SecondaryBurstRate", "PacketBurstFrequency", "Range"], timetableThis.Properties.VariableNames);
            timetableThis(:, fillVariables) = fillmissing(timetableThis(:, fillVariables), "previous");

            timetableThis{contains(timetableThis.Label, "Config"), ["PrimaryNormalRate", "SecondaryNormalRate", "PacketNormalFrequency", "PrimaryBurstRate", "SecondaryBurstRate", "PacketBurstFrequency", "Duration"]} = missing();
            timetableThis{contains(timetableThis.Label, "Ramp"), "Range"} = missing();
        end

        function eventtableThis = eventtable(this)
        % EVENTTABLE Convert evnets to eventtable.

            eventtableThis = this.timetable();
            eventtableThis.Reason = repmat("Command", height(eventtableThis), 1);

            locTimedCommand = ~ismissing(eventtableThis.Duration) & (eventtableThis.Duration ~= 0);

            idxTimedCommand = find(locTimedCommand);
            idxBaselineCommand = find(~locTimedCommand);

            for i = idxTimedCommand(:)'

                idx = idxBaselineCommand(idxBaselineCommand < i);
                assert(~isempty(idx), "Cannot determine initial event.");

                autoEvent = eventtableThis(i, :);
                autoEvent.Time = eventtableThis.Time(i) + seconds(eventtableThis.Duration(i));
                autoEvent.Mode = eventtableThis.Mode(idx(end));
                autoEvent.Duration = 0;
                autoEvent.Reason = "Auto";

                if isequal(autoEvent.Mode, "Normal")
                    autoEvent.Label = compose("Normal (%d, %d)", autoEvent.PrimaryNormalRate, autoEvent.SecondaryNormalRate);
                else
                    autoEvent.Label = compose("Burst (%d, %d)", autoEvent.PrimaryBurstRate, autoEvent.SecondaryBurstRate);
                end

                eventtableThis = [eventtableThis; autoEvent]; %#ok<AGROW>
            end

            eventtableThis = sortrows(eventtableThis);
            eventtableThis = eventtable(eventtableThis, EventLabelsVariable = "Label");
        end
    end

    methods (Abstract, Access = protected)

        % CONVERTTOTIMETABLE Convert event to timetable.
        tableThis = convertToTimeTable(this)
    end

    methods (Access = protected)

        function timestamps = getTimestamps(this)

            timestamps = [this.CompleteTimestamp];
            locMissing = ismissing(timestamps);

            if any(locMissing)

                timestamps(locMissing) = [this(locMissing).AcknowledgeTimestamp];
                locMissing = ismissing(timestamps);
            
                if any(locMissing)
                    timestamps(locMissing) = this(locMissing).CommandTimestamp;
                end
            end
        end
    end
end
