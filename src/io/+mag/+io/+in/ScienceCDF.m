classdef ScienceCDF < mag.io.in.CDF
% SCIENCECDF Format science data for CDF import.

    properties (Constant, Access = private)
        FileNamePattern (1, 1) string = "imap_mag_(?<level>.+?)_(?<mode>\w+?)-mag(?<sensor>\w)_(?<date>\d+)_(?<version>.+?)\.cdf"
    end

    properties
        % TIMESTAMP Name of timestamp property in CDF file.
        Timestamp (1, 1) pattern = "EPOCH"
        % FIELD Name of field property in CDF file.
        Field (1, 1) pattern = "B_MAG" + wildcardPattern() + "_URF"
        % RANGE Name of range property in CDF file.
        Range (1, 1) pattern = "VECTOR_RANGE"
    end

    methods

        function this = ScienceCDF(options)

            arguments
                options.?mag.io.in.ScienceCDF
            end

            this.assignProperties(options)
        end

        function data = process(this, rawData, cdfInfo)

            arguments (Input)
                this
                rawData cell
                cdfInfo (1, 1) struct
            end

            arguments (Output)
                data (1, 1) mag.Science
            end

            % Extract file meta data.
            [~, mode, sensor, date, ~] = this.extractFileMetaData(cdfInfo.Filename);

            % Extract raw data.
            [rawTimestamps, rawField, rawRange] = this.extractRawCDFData(rawData, cdfInfo);

            % Convert timestamps to datetime.
            timestamps = datetime(rawTimestamps, InputFormat = "uuuu-MM-dd'T'HH:mm:ss.SSS", ...
                Format = mag.time.Constant.Format, TimeZone = mag.time.Constant.TimeZone);

            % Create science timetable.
            timedData = timetable(timestamps, (1:numel(timestamps))', ...
                rawField(:, 1), rawField(:, 2), rawField(:, 3), rawRange, ...
                false(height(timestamps), 1), repmat(mag.meta.Quality.Regular, height(timestamps), 1), ...
                VariableNames = ["sequence", "x", "y", "z", "range", "compression", "quality"]);

            % Add continuity information, for simpler interpolation.
            % Property order:
            %     sequence, x, y, z, range, compression, quality
            timedData.Properties.VariableContinuity = ["step", "continuous", "continuous", "continuous", "step", "step", "step"];

            % Create mag.Science object with meta data.
            metaData = mag.meta.Science(Mode = mode, Primary = isequal(sensor, mag.meta.Sensor.FOB), Sensor = sensor, ...
                Timestamp = datetime(date, InputFormat = "uuuuMMdd", Format = mag.time.Constant.Format, TimeZone = mag.time.Constant.TimeZone));
            data = mag.Science(timedData, metaData);
        end
    end

    methods (Access = private)

        function [level, mode, sensor, date, version] = extractFileMetaData(this, fileName)
        % EXTRACTMETADATA Extract meta data information from file name.

            details = regexp(fileName, this.FileNamePattern, "names");
            [level, date, version] = deal(details.level, details.date, details.version);

            switch details.sensor
                case "o"
                    sensor = mag.meta.Sensor.FOB;
                case "i"
                    sensor = mag.meta.Sensor.FIB;
                otherwise
                    error("Unsupported sensor ""%s"".");
            end

            switch details.mode
                case "burst"
                    mode = mag.meta.Mode.Burst;
                case "normal"
                    mode = mag.meta.Mode.Normal;
                case "ialirt"
                    mode = mag.meta.Mode.IALiRT;
                otherwise
                    error("Unsupported mode ""%s"".");
            end
        end

        function [rawTimestamps, rawField, rawRange] = extractRawCDFData(this, rawData, cdfInfo)
        % EXTRACTRAWCDFDATA Extract raw values from CDF table.

            variableNames = cdfInfo.Variables(:, 1);

            rawTimestamps = rawData{matches(variableNames, this.Timestamp)};

            if isequal(this.Field, this.Range)

                rawField = rawData{matches(variableNames, this.Field)}(:, 1:3);
                rawRange = rawData{matches(variableNames, this.Range)}(:, 4);
            else

                rawField = rawData{matches(variableNames, this.Field)};
                rawRange = rawData{matches(variableNames, this.Range)};
            end
        end
    end
end
