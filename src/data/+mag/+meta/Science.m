classdef Science < mag.meta.Data
% SCIENCE Description of MAG science data.

    properties (Constant, Hidden)
        MetaDataFilePattern (1, 1) string = "MAGScience-(?<mode>\w+)-\((?<primaryFrequency>\d+),(?<secondaryFrequency>\d+)\)-(?<packetFrequency>\d+)s-(?<date>\d+)-(?<time>\w+).(?<extension>\w+)"
    end

    properties
        % MODEL Sensor model type and number.
        Model string {mustBeScalarOrEmpty, mustMatchRegex(Model, "^[LEF]M\d$")}
        % FEE FEE id.
        FEE string {mustBeScalarOrEmpty, mustMatchRegex(FEE, "^FEE\d$")}
        % CAN Can holding sensor.
        Can string {mustBeScalarOrEmpty}
        % SENSOR Sensor type.
        Sensor mag.meta.Sensor {mustBeScalarOrEmpty}
        % MODE Selected mode.
        Mode string {mustBeScalarOrEmpty, mustBeMember(Mode, ["Normal", "Burst", "Hybrid", "I-ALiRT"])} = "Hybrid"
        % DATAFREQUENCY Frequency of data (how many vectors per second).
        DataFrequency (1, 1) double = NaN
        % PACKETFREQUENCY Frequency of packets (how often packets are
        % received).
        PacketFrequency (1, 1) double = NaN
        % REFERENCEFRAME Reference frame of magnetic field data.
        ReferenceFrame string {mustBeScalarOrEmpty} = string.empty()
    end

    methods

        function this = Science(options)

            arguments
                options.?mag.meta.Science
            end

            this.assignProperties(options);
        end
    end
end

function mustMatchRegex(value, pattern)

    if ~isempty(value) && ~matches(value, regexpPattern(pattern))
        error("Value ""%s"" does not match patter ""%s"".", value, pattern);
    end
end
