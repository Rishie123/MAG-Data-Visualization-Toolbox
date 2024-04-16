classdef ScienceCSV < mag.io.in.CSV
    % SCIENCECSV Format science data for CSV import.

    properties (Constant, Access = private)
        FileNamePattern (1, 1) string = "MAGScience-(?<mode>\w+)-\((?<primaryFrequency>\d+),(?<secondaryFrequency>\d+)\)-(?<packetFrequency>\d+)s-(?<date>\d+)-(?<time>\w+).(?<extension>\w+)"
    end

    methods

        function combinedData = combineByType(~, data)

            arguments (Input)
                ~
                data (1, :) mag.Science
            end

            arguments (Output)
                combinedData (1, :) mag.Science
            end

            combinedData = mag.Science.empty();

            % Combine data by sensor.
            metaData = [data.MetaData];
            sensors = unique([metaData.Sensor]);

            for s = sensors

                locSelection = [metaData.Sensor] == s;
                selectedData = data(locSelection);

                td = vertcat(selectedData.Data);

                md = selectedData(1).MetaData.copy();
                md.set(Mode = "Hybrid", DataFrequency = NaN(), PacketFrequency = NaN(), Timestamp = min([metaData(locSelection).Timestamp]));

                combinedData(end + 1) = mag.Science(td, md); %#ok<AGROW>
            end
        end
    end

    methods (Access = protected)

        function data = convert(this, rawData, fileName)

            arguments (Input)
                this
                rawData table
                fileName (1, 1) string
            end

            arguments (Output)
                data (1, :) mag.Science
            end

            % Separate primary and secondary.
            rawPrimary = rawData(:, regexpPattern(".*(pri|sequence).*"));
            rawSecondary = rawData(:, regexpPattern(".*(sec|sequence).*"));

            % Extract file meta data.
            [mode, primaryFrequency, secondaryFrequency, packetFrequency] = this.extractFileMetaData(fileName);

            % Process science data.
            data = [this.processScience(rawPrimary, "pri", Sensor = mag.meta.Sensor.FOB, Mode = mode, DataFrequency = primaryFrequency, PacketFrequency = packetFrequency), ...
                this.processScience(rawSecondary, "sec", Sensor = mag.meta.Sensor.FIB, Mode = mode, DataFrequency = secondaryFrequency, PacketFrequency = packetFrequency)];
        end
    end

    methods (Access = private)

        function [mode, primaryFrequency, secondaryFrequency, packetFrequency] = extractFileMetaData(this, fileName)
        % EXTRACTMETADATA Extract meta data information from file name.

            rawData = regexp(fileName, this.FileNamePattern, "names");

            % If no meta data was found, assume default values.
            if isempty(rawData)

                if contains(fileName, "ialirt", IgnoreCase = true)

                    mode = "IALiRT";
                    primaryFrequency = "0.25";
                    secondaryFrequency = "0.25";
                    packetFrequency = "4";
                elseif contains(fileName, "normal", IgnoreCase = true)

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
            metaData = mag.meta.Science(metaDataArgs{:}, Primary = isequal(sensor, "pri"));

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
            %     sequence, x, y, z, range, coarse, fine, compression,
            %     quality, t
            rawData.Properties.VariableContinuity = ["step", "continuous", "continuous", "continuous", "step", "continuous", "continuous", "step", "step", "continuous"];

            % Convert to mag.Science.
            data = mag.Science(table2timetable(rawData, RowTimes = "t"), metaData);
        end
    end

    methods (Static, Access = private)

        function assignSensor(property, output, data)
        % ASSIGNSENSOR Assign value of sensor to output.

            if isempty(output.(property))
                output.(property).Science(end + 1) = mag.Science(data.(property).Data, data.(property).MetaData);
            else
                output.(property).Data = vertcat(output.(property).Data, data.Data);
            end
        end
    end
end
