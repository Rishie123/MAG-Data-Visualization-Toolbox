classdef Timestamp < mag.process.Step
% TIMESTAMP Adjust timestamp of data points based on frequency of data.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties (SetAccess = private)
        % MISTIMEDPACKETS Counter for number of packets with wrong
        % timestamp.
        MistimedPackets (1, 1) double
    end

    methods

        function value = get.Name(~)
            value = "Adjust Timestamp";
        end

        function value = get.Description(~)
            value = "Coarse timestamps are adjusted based on sensor mode and with fine timestamp data.";
        end

        function value = get.DetailedDescription(this)

            value = this.Description + " Sensor mode is used to determine the time difference between each " + ...
                "data point (data points in a packet are returned with the same timestamp, which needs to be adjusted). " + ...
                "Moreover, fine timestamp data is added, to achieve a more precise estimate. This step also checks for " + ...
                "mistimed packets: " + this.MistimedPackets + " mistimed packet(s) encountered during this processing session.";
        end

        function data = apply(this, data, metaData)
            data = this.computeTimeStamp(data, metaData.DataFrequency, metaData.PacketFrequency);
        end
    end

    methods (Hidden)

        function data = computeTimeStamp(this, data, dataFrequency, packetFrequency)

            arguments (Input)
                this
                data
                dataFrequency (1, 1) double
                packetFrequency (1, 1) double
            end

            arguments (Output)
                data %{mustBeIncreasing}
            end

            coarseAndFineTime = data{:, ["coarse", "fine"]};
            sequence = data.sequence;

            % Remove discontinuities in sequence number.
            sequence = this.correctSequence(sequence);
            vectorsPerPacket = dataFrequency * packetFrequency;

            [uniqueSequence, idxSequence] = unique(sequence);
            if any(diff(idxSequence) ~= vectorsPerPacket)

                corruptPackets = uniqueSequence(diff(idxSequence) ~= vectorsPerPacket);
                % error("The following packets do not contain %d elements:\n    %s", vectorsPerPacket, join(compose("%d, ", corruptPackets)));
                data(ismember(sequence, corruptPackets), :) = [];

                coarseAndFineTime = data{:, ["coarse", "fine"]};
                sequence = this.correctSequence(data.sequence);
            end

            % Correct coarse time if incorrect.
            actualPacketFrequency = diff(coarseAndFineTime(:, 1));
            locMistimed = (actualPacketFrequency ~= 0) & (actualPacketFrequency ~= packetFrequency);

            if any(locMistimed)

                this.MistimedPackets = nnz(locMistimed);
                warning("%d packets with wrong timestamp.", this.MistimedPackets);
            end

            % Determine time offset to add.
            timeOffset = linspace(0, packetFrequency, vectorsPerPacket + 1);
            timeOffset = timeOffset(1:end-1)';

            numPackets = sequence(end) - sequence(1) + 1;
            timeOffset = repmat(timeOffset, [numPackets, 1]);

            % If last packet was interrupted, crop time offset.
            sizeDifference = numel(timeOffset) - size(coarseAndFineTime, 1);
            assert(sizeDifference >= 0, "Size difference must be greater or equal to zero.");

            if sizeDifference ~= 0
                timeOffset(end-(sizeDifference-1):end) = [];
            end

            % Add time offset to all timestamps.
            timeStamp = coarseAndFineTime(:, 1) + (coarseAndFineTime(:, 2) / double(intmax("uint16")));
            data.t = timeStamp + timeOffset;
        end
    end
end

function mustBeIncreasing(value)

    if ~all(diff(value) > 0)
        error("Value should be increasing.");
    end
end
