classdef Instrument < mag.meta.Data
% INSTRUMENT Description of MAG instrument data.

    properties
        % MODEL Instrument model type.
        Model string {mustBeScalarOrEmpty, mustBeMember(Model, ["LM", "EM", "FM"])}
        % PRIMARY Primary sensor.
        Primary (1, 1) mag.meta.Sensor = "FOB"
        % BSW Boot sowftware version.
        BSW string {mustBeScalarOrEmpty}
        % ASW App software version.
        ASW string {mustBeScalarOrEmpty}
        % OPERATOR Operator running experiment.
        Operator string {mustBeScalarOrEmpty}
        % ATTEMPTS Number of attempts to start FOB and FIB.
        Attemps (1, 2) double = NaN(1, 2)
    end

    methods

        function this = Instrument(options)

            arguments
                options.?mag.meta.Instrument
            end

            this.assignProperties(options);
        end
    end
end
