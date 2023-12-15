classdef ModeChange < mag.event.Event
% MODECHANGE Description of a mode change event.

    properties (Constant)
        SpecificFormat = ""
    end

    properties
        % MODE Mode being changed to.
        Mode (1, 1) string {mustBeMember(Mode, ["Config", "Normal", "Burst"])} = "Normal"
        % PRIMARYRATE Rate of primary sensor.
        PrimaryRate (1, 1) double {mustBeMemberOrMissing(PrimaryRate, [1, 2, 4, 8, 64, 128])} = 1
        % SECONDARYRATE Rate of secondary sensor.
        SecondaryRate (1, 1) double {mustBeMemberOrMissing(SecondaryRate, [1, 2, 4, 8, 64, 128])} = 1
        % PACKETFREQUENCY Frequency of data packets.
        PacketFrequency (1, 1) double {mustBeMemberOrMissing(PacketFrequency, [2, 4, 8])} = 2
        % DURATION Duration of burst mode.
        Duration (1, 1) double = 0
    end

    methods

        function this = ModeChange(options)

            arguments
                options.?mag.event.ModeChange
            end

            this.assignProperties(options);
        end
    end

    methods (Access = protected)

        function tableThis = convertToTimeTable(this)

            labels = compose("%s (%d, %d)", [this.Mode]', [this.PrimaryRate]', [this.SecondaryRate]');

            tableThis = timetable([this.Mode], [this.PrimaryRate], [this.SecondaryRate], [this.PacketFrequency], [this.Duration], labels, ...
                RowTimes = [this.CompleteTimestamp], VariableNames = ["Mode", "PrimaryRate", "SecondaryRate", "PacketFrequency", "Duration", "Label"]);
        end
    end
end

function mustBeMemberOrMissing(value, allowed)

    if ~ismissing(value)
        mustBeMember(value, allowed);
    end
end
