classdef ScienceCDF < mag.io.in.CDF
% SCIENCECDF Format science data for CDF import.

    properties (Constant, Access = private)
        FileNamePattern (1, 1) string = "imap_mag_(?<level>.+?)_(?<mode>\w+?)-mag(?<sensor>\w)_(?<date>\d+)_(?<version>.+?)\.cdf"
    end

    methods

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

            % Convert timestamps to datetime.
            timestamps = datetime(rawData{2}, InputFormat = "uuuu-MM-dd'T'HH:mm:ss.SSS", ...
                Format = mag.time.Constant.Format, TimeZone = mag.time.Constant.TimeZone);

            % Create science timetable.
            timedData = timetable(timestamps, (1:numel(timestamps))', ...
                rawData{1}(:, 1), rawData{1}(:, 2), rawData{1}(:, 3), rawData{1}(:, 4), ...
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
    end
end
