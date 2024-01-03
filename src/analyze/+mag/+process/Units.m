classdef Units < mag.process.Step
% UNITS Convert from engineering units.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties (Constant, Access = private)
        % SCALEFACTORS Scale factors for engineering unit conversions.
        ScaleFactors (1, 1) dictionary = dictionary( ...
            P1V5V = 0.00080322, ...
            P1V8V = 0.00080322, ...
            P3V3V = 0.001164028, ...
            P2V5V = 0.00080322, ...
            P8V = 0.002576341, ...
            N8V = -0.002591041, ...
            P2V4V = 0.001164028, ...
            P1V5I = 0.238840321, ...
            P1V8I = 0.079550361, ...
            P3V3I = 0.07964502, ...
            P2V5I = 0.052732405, ...
            P8VI = 0.1193, ...
            N8VI = 0.1178, ...
            ICU_TEMP = 0.1235727, ...
            FIB_TEMP = 0.1171337327, ...
            FOB_TEMP = 0.1171337327)
        % OFFSETS Offsets for engineering unit conversions.
        Offsets (1, 1) dictionary = dictionary( ...
            P1V5V = 0, ...
            P1V8V = 0, ...
            P3V3V = 0, ...
            P2V5V = 0, ...
            P8V = 0, ...
            N8V = 0, ...
            P2V4V = 0, ...
            P1V5I = -2.0944, ...
            P1V8I = -9.8839, ...
            P3V3I = -13.655, ...
            P2V5I = -9.8261, ...
            P8VI = -9.5705, ...
            N8VI = -8.3906, ...
            ICU_TEMP = -273.15, ...
            FIB_TEMP = -293.187, ...
            FOB_TEMP = -293.187)
    end

    methods

        function value = get.Name(~)
            value = "Convert from Engineering Units";
        end

        function value = get.Description(~)
            value = "Convert engineering units to scientific units, depending on the type of housekeeping data.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description + " Scale factors and offsets are applied to obtain regular scientific units.";
        end

        function data = apply(this, data, metaData)

            arguments
                this
                data table
                metaData (1, 1) mag.meta.HK
            end

            switch metaData.Type
                case "PW"
                    data = this.convertPowerEngineeringUnits(data);
                case "SID15"

                    data = this.convertPowerEngineeringUnits(data);

                    for drt = ["ISV_FOB_DTRDYTM", "ISV_FIB_DTRDYTM"]
                        data{:, drt} = this.convertDataReadyTime(data{:, drt});
                    end

                case {"PROCSTAT", "STATUS"}
                    % nothing to do
                otherwise
                    error("Unrecognized HK type ""%s"".", metaData.Type);
            end
        end
    end

    methods (Access = private)

        function data = convertPowerEngineeringUnits(this, data)
        % CONVERTPOWERENGINEERINGUNITS Convert power data from engineering
        % units to scientific units.

            variableNames = string(data.Properties.VariableNames);

            for k = keys(this.ScaleFactors)'

                vn = variableNames(matches(variableNames, regexpPattern(k)));
                data{:, vn} = (data{:, vn} * this.ScaleFactors(k)) + this.Offsets(k);
            end
        end
    end

    methods (Static, Access = private)

        function readyTime = convertDataReadyTime(readyTime)
        % CONVERTDATAREADYTIME Convert data ready time to pseudo-timestamp.

            binRT = dec2bin(readyTime);

            fineTime = bin2dec(binRT(:, end-23:end));
            fineTime = fineTime / (2^24-1);

            coarseTime = bin2dec(binRT(:, 1:end-24));
            readyTime = coarseTime + fineTime;
        end
    end
end
