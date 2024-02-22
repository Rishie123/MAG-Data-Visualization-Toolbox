classdef Excel < mag.meta.log.Type
% EXCEL Load meta data from Excel files.

    properties (Constant)
        Extensions = [".xlsx", ".xls"]
        % ACTIVATIONPATTERN Regex pattern to extract number of attempts to
        % start up the sensors.
        ActivationPattern (1, 1) string = "^\s*FOB:\s*(?<fob>\d+)?.*?FIB:\s*(?<fib>\d+)?.*?Repeat activation\?:\s*(:?y\/n)?\s*(?<repeat>.*?)?\s*$"
        % SENSORPATTERN Regex pattern to extract sensor meta data.
        SensorPattern (1, 1) string = "(?<fee>FEE\d).*?,\s*(?<harness>.+?)\s*,.*?(?<model>[LEF]M\d)\s*(?<can>\(.*?\))?"
    end

    methods

        function this = Excel(options)

            arguments
                options.?mag.meta.log.Excel
            end

            this.assignProperties(options);
        end
    end

    methods (Hidden)

        function [instrumentMetaData, primaryMetaData, secondaryMetaData] = load(this, instrumentMetaData, primaryMetaData, secondaryMetaData)

            arguments (Input)
                this
                instrumentMetaData (1, 1) mag.meta.Instrument
                primaryMetaData (1, :) mag.meta.Science
                secondaryMetaData (1, :) mag.meta.Science
            end

            arguments (Output)
                instrumentMetaData (1, 1) mag.meta.Instrument
                primaryMetaData (1, :) mag.meta.Science
                secondaryMetaData (1, :) mag.meta.Science
            end

            % Read meta data file.
            importOptions = spreadsheetImportOptions(NumVariables = 9, VariableTypes = repmat("string", 1, 9), Sheet = "Sheet1");

            rawData = readtable(this.FileName, importOptions);
            rawData = rmmissing(rawData, 1, MinNumMissing = size(rawData, 2));
            rawData = rmmissing(rawData, 2, MinNumMissing = size(rawData, 1));

            % Extract sensor meta data.
            primaryDetails = regexp(rawData{3, "Var6"}, this.SensorPattern, "once", "names");
            secondaryDetails = regexp(rawData{4, "Var6"}, this.SensorPattern, "once", "names");

            assert(~isempty(primaryDetails), "No meta data detected for FOB.");
            assert(~isempty(secondaryDetails), "No meta data detected for FIB.");

            % Extract activation meta data.
            data = join(rmmissing(rawData{:, "Var1"}), newline);

            if contains(data, "SFT", IgnoreCase = true)

                attempts.fob = NaN;
                attempts.fib = NaN;
            else

                attempts = regexp(data, this.ActivationPattern, "once", "names", "dotexceptnewline", "lineanchors");
                assert(~isempty(attempts), "No meta data detected for activation attempts.");

                if ~contains(attempts.repeat, "n", IgnoreCase = true)

                    warning("Manual intervention required. Cannot determine number of activation attemps. Detected values are: FOB ""%s"", FIB ""%s"", Repeat ""%s"".", attempts.fob, attempts.fib, attempts.repeat);
                    attempts.fob = NaN;
                    attempts.fib = NaN;
                end
            end

            % Assign instrument meta data.
            instrumentMetaData.Model = extract(rawData{4, "Var3"}, regexpPattern("[LEF]M"));
            instrumentMetaData.BSW = rawData{5, "Var3"};
            instrumentMetaData.ASW = rawData{5, "Var7"};
            instrumentMetaData.Attemps = [attempts.fob, attempts.fib];
            instrumentMetaData.Operator = rawData{3, "Var3"};
            instrumentMetaData.Description = rawData{6, "Var7"};
            instrumentMetaData.Timestamp = datetime(rawData{6, "Var3"}, TimeZone = "local", Format = mag.time.Constant.Format) + ...
                duration(regexp(data, "^Time: ([\w:]+)$", "once", "tokens", "dotexceptnewline", "lineanchors"), InputFormat = "hh:mm");

            % Enhance primary and secondary meta data.
            [primaryMetaData.Model] = deal(primaryDetails.model);
            [primaryMetaData.FEE] = deal(primaryDetails.fee);
            [primaryMetaData.Harness] = deal(primaryDetails.harness);

            if isfield(primaryDetails, "can")

                [primaryMetaData.Can] = deal(primaryDetails.can);
                [primaryMetaData.Can] = extractBetween([primaryMetaData.Can], "(", ")");
            end

            [secondaryMetaData.Model] = deal(secondaryDetails.model);
            [secondaryMetaData.FEE] = deal(secondaryDetails.fee);
            [secondaryMetaData.Harness] = deal(secondaryDetails.harness);

            if isfield(primaryDetails, "can")

                [secondaryMetaData.Can] = deal(secondaryDetails.can);
                [secondaryMetaData.Can] = extractBetween([secondaryMetaData.Can], "(", ")");
            end
        end
    end
end
