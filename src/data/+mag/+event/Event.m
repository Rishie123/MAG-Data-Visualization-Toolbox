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

        function tableThis = timetable(this)
        % TIMETABLE Convert events to timetable.

            emptyTime = datetime.empty();
            emptyTime.TimeZone = "UTC";

            tableThis = struct2table(struct(Time = emptyTime, ...
                Mode = double.empty(0, 1), ...
                PrimaryRate = double.empty(0, 1), ...
                SecondaryRate = double.empty(0, 1), ...
                PacketFrequency = double.empty(0, 1), ...
                Duration = double.empty(0, 1), ...
                Range = double.empty(0, 1), ...
                Sensor = string.empty(0, 1), ...
                Label = string.empty(0, 1)));
            tableThis = table2timetable(tableThis, RowTimes = "Time");

            for t = 1:numel(this)

                tt = this(t).convertToTimeTable();
                tableThis = outerjoin(tableThis, tt, MergeKeys = true, Keys = ["Time", intersect(tableThis.Properties.VariableNames, tt.Properties.VariableNames)]);
            end

            tableThis = sortrows(tableThis);

            fillVariables = intersect(["Mode", "PrimaryRate", "SecondaryRate", "PacketFrequency", "Range"], tableThis.Properties.VariableNames);
            tableThis(:, fillVariables) = fillmissing(tableThis(:, fillVariables), "previous");

            tableThis{contains(tableThis.Label, "Config"), ["PrimaryRate", "SecondaryRate", "PacketFrequency", "Duration"]} = missing();
            tableThis{contains(tableThis.Label, "Ramp"), "Range"} = missing();
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
