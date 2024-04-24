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
            ICU_TEMP = 0.1235727)
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
            ICU_TEMP = -273.15)
        % FOBTEMPERATUREFIT FOB temperature fit function.
        FOBTemperatureFit (1, 1) function_handle = mag.process.Units.fitFOBTemperature()
        % FIBTEMPERATUREFIT FIB temperature fit function.
        FIBTemperatureFit (1, 1) function_handle = mag.process.Units.fitFIBTemperature()
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
                data tabular
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

            % Convert currents and voltages.
            variableNames = string(data.Properties.VariableNames);

            for k = keys(this.ScaleFactors)'

                vn = variableNames(matches(variableNames, regexpPattern(k)));
                data{:, vn} = (data{:, vn} * this.ScaleFactors(k)) + this.Offsets(k);
            end

            % Convert FOB temperature.
            locFOB = regexpPattern("(ISV_)?FOB_TEMP");
            data{:, locFOB} = this.FOBTemperatureFit(data{:, locFOB});

            % Convert FIB temperature.
            locFIB = regexpPattern("(ISV_)?FIB_TEMP");
            data{:, locFIB} = this.FIBTemperatureFit(data{:, locFIB});
        end
    end

    methods (Static, Access = private)

        function f = fitFOBTemperature()
        % FITFOBTEMPERATURE Fit FOB temperature with a 3rd degree
        % polynomial.

            x = [1950; 1999; 2044; 2085; 2143; 2193; 2247; 2262; 2354; 2407; 2463; 2510; 2560; 2629; 2677; 2692; 2804; 2856; 2910; 2919; 2975; 3034];
            y = [-59.1; -54.1; -49.5; -45.2; -39.4; -34.4; -28.8; -27; -17.6; -12; -6.1; -1.3; 4.6; 12; 17.7; 18.7; 32.7; 38.9; 45.6; 46.1; 53.9; 62];

            p = polyfit(x, y, 3);
            f = @(x) p(1) * x.^3 + p(2) * x.^2 + p(3) * x + p(4);
        end

        function f = fitFIBTemperature()
        % FITFIBTEMPERATURE Fit FIB temperature with a 3rd degree
        % polynomial.

            x = [1949; 1997; 2042; 2083; 2141; 2190; 2243; 2257; 2348; 2400; 2454; 2499; 2548; 2614; 2660; 2675; 2780; 2830; 2879; 2888; 2940; 2994];
            y = [-59.1; -54.1; -49.5; -45.5; -39.4; -34.4; -28.8; -27; -17.6; -12; -5.9; -1.3; 4.6; 12; 17.4; 18.7; 32.7; 38.9; 45.6; 46.1; 53.9; 62];

            p = polyfit(x, y, 3);
            f = @(x) p(1) * x.^3 + p(2) * x.^2 + p(3) * x + p(4);
        end

        function readyTime = convertDataReadyTime(readyTime)
        % CONVERTDATAREADYTIME Convert data ready time to pseudo-timestamp.

            binRT = dec2bin(readyTime);

            if width(binRT) < 24
                binRT = char(pad(string(binRT), 25, "left", "0"));
            end

            fineTime = bin2dec(binRT(:, end-23:end));
            fineTime = fineTime / (2^24-1);

            coarseTime = bin2dec(binRT(:, 1:end-24));
            readyTime = coarseTime + fineTime;
        end
    end
end
