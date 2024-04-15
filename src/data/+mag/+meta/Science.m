classdef Science < mag.meta.Data
% SCIENCE Description of MAG science data.

    properties
        % PRIMARY Boolean denoting whether sensor is primary.
        Primary (1, 1) logical = false
        % MODEL Sensor model type and number.
        Model string {mustBeScalarOrEmpty, mag.validator.mustMatchRegex(Model, "^[LEF]M\d$")}
        % FEE FEE id.
        FEE string {mustBeScalarOrEmpty, mag.validator.mustMatchRegex(FEE, "^FEE\d$")}
        % HARNESS Harness connecting sensor to electronics box.
        Harness string {mustBeScalarOrEmpty}
        % CAN Can containing sensor.
        Can string {mustBeScalarOrEmpty}
        % SENSOR Sensor type.
        Sensor mag.meta.Sensor {mustBeScalarOrEmpty}
        % MODE Selected mode.
        Mode mag.meta.Mode {mustBeScalarOrEmpty} = mag.meta.Mode.Hybrid
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
