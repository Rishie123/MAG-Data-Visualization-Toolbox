classdef ScienceCSV < mag.io.in.CSV
% SCIENCECSV Format science data for CSV import.

    properties (Constant, Access = private)
        FileNamePattern (1, 1) string = "MAGScience-(?<mode>\w+)-\((?<primaryFrequency>\d+),(?<secondaryFrequency>\d+)\)-(?<packetFrequency>\d+)s-(?<date>\d+)-(?<time>\w+).(?<extension>\w+)"
    end

    methods

        function data = convert(this, rawData, fileName)

            arguments (Input)
                this
                rawData table
                fileName (1, 1) string
            end

            arguments (Output)
                data (1, 1) {mustBeA(data, ["mag.Instrument", "mag.IALiRT"])}
            end

            % Separate primary and secondary.
            rawPrimary = rawData(:, regexpPattern(".*(pri|sequence).*"));
            rawSecondary = rawData(:, regexpPattern(".*(sec|sequence).*"));

            % Extract file meta data.
            [mode, primaryFrequency, secondaryFrequency, packetFrequency] = this.extractFileMetaData(fileName);

            % Process science data.
            if mode == mag.meta.Mode.IALiRT
                data = mag.IALiRT();
            else
                data = mag.Instrument();
            end

            data.Primary = this.processScience(rawPrimary, "pri", Mode = mode, DataFrequency = primaryFrequency, PacketFrequency = packetFrequency);
            data.Secondary = this.processScience(rawSecondary, "sec", Mode = mode, DataFrequency = secondaryFrequency, PacketFrequency = packetFrequency);
        end

        function applyProcessingSteps(~, data, processingSteps)

            arguments
                ~
                data (1, 1) {mustBeA(data, ["mag.Instrument", "mag.IALiRT"])}
                processingSteps (1, :) mag.process.Step
            end

            for ps = processingSteps

                data.Primary.Data = ps.apply(data.Primary.Data, data.Primary.MetaData);
                data.Secondary.Data = ps.apply(data.Secondary.Data, data.Secondary.MetaData);
            end
        end

        function assignToOutput(this, output, data)

            arguments
                this (1, 1) mag.io.in.ScienceCSV
                output (1, 1) {mustBeA(output, ["mag.Instrument", "mag.IALiRT"])}
                data (1, 1) mag.Instrument
            end

            this.assignSensor("Primary", output, data);
            this.assignSensor("Secondary", output, data);
        end
    end

    methods (Access = private)

        function [mode, primaryFrequency, secondaryFrequency, packetFrequency] = extractFileMetaData(this, fileName)
        % EXTRACTMETADATA Extract meta data information from file name.

            rawData = regexp(fileName, this.FileNamePattern, "names");

            % If no meta data was found, assume default values.
            if isempty(rawData)

                if contains(fileName, "normal", IgnoreCase = true)

                    mode = "Normal";
                    primaryFrequency = "2";
                    secondaryFrequency = "2";
                    packetFrequency = "8";
                elseif contains(fileName, "burst", IgnoreCase = true)

                    mode = "Burst";
                    primaryFrequency = "128";
                    secondaryFrequency = "128";
                    packetFrequency = "2";
                else
                    error("Unrecognized file name format for ""%s"".", fileName);
                end

            % Otherwise, extract from file name.
            else

                mode = regexprep(rawData.mode, "(\w)(\w+)", "${upper($1)}$2");

                primaryFrequency = rawData.primaryFrequency;
                secondaryFrequency = rawData.secondaryFrequency;
                packetFrequency = rawData.packetFrequency;
            end
        end

        function data = processScience(~, rawData, sensor, metaDataOptions)
        % PROCESSSCIENCE Process science data.

            arguments
                ~
                rawData table
                sensor (1, 1) string {mustBeMember(sensor, ["pri", "sec"])}
                metaDataOptions.?mag.meta.Science
            end

            metaDataArgs = namedargs2cell(metaDataOptions);
            metaData = mag.meta.Science(metaDataArgs{:});

            % Rename variables.
            newVariableNames = ["x", "y", "z", "range", "coarse", "fine"];
            rawData = renamevars(rawData, [["x", "y", "z", "rng"] + "_" + sensor, sensor + "_" + ["coarse", "fine"]], newVariableNames);

            % Add compression and quality flags.
            rawData.compression = false(height(rawData), 1);
            rawData.quality = repmat(mag.meta.Quality.Regular, height(rawData), 1);

            % Convert timestamps.
            for ps = [mag.process.Timestamp(), mag.process.DateTime()]
                rawData = ps.apply(rawData, metaData);
            end

            % Add continuity information, for simpler interpolation.
            % Property order:
            %     sequence, x, y, z, range, coarse, fine, compression, quality
            rawData.Properties.VariableContinuity = ["step", "continuous", "continuous", "continuous", "step", "continuous", "continuous", "step", "step"];

            % Convert to mag.Science.
            data = mag.Science(table2timetable(rawData, RowTimes = "t"), metaData);
        end
    end

    methods (Static, Access = private)

        function assignSensor(property, output, data)
        % ASSIGNSENSOR Assign value of sensor to output.

            if isempty(output.(property))
                output.(property) = mag.Science(data.(property).Data, data.(property).MetaData);
            else
                output.(property).Data = vertcat(output.(property).Data, data.(property).Data);
            end
        end
    end
end
