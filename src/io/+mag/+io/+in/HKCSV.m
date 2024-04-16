classdef HKCSV < mag.io.in.CSV
% HKCSV Format HK data for CSV import.

    properties (Constant, Access = private)
        FileNamePattern (1, 1) string = "idle_export_\w+.MAG_HSK_(?<type>\w+)_(?<date>\d+)_(?<time>\w+).(?<extension>\w+)"
    end

    methods

        function combinedData = combineByType(~, data)

            arguments (Input)
                ~
                data (1, :) mag.HK
            end

            arguments (Output)
                combinedData (1, :) mag.HK
            end

            combinedData = mag.HK.empty();

            % Combine data by sensor.
            metaData = [data.MetaData];
            types = unique([metaData.Type]);

            for t = types

                locSelection = [metaData.Type] == t;
                selectedData = data(locSelection);

                td = vertcat(selectedData.Data);

                md = selectedData(1).MetaData.copy();
                md.set(Timestamp = min([metaData(locSelection).Timestamp]));

                combinedData(end + 1) = mag.hk.dispatchHKType(td, md); %#ok<AGROW>
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
                data (1, 1) mag.HK
            end

            rawData = renamevars(rawData, "SHCOARSE", "t");

            % Convert timestamps.
            for ps = [mag.process.DateTime()]
                rawData = ps.apply(rawData, mag.meta.HK());
            end

            % Dispatch correct type.
            data = mag.hk.dispatchHKType(table2timetable(rawData, RowTimes = "t"), this.extractFileMetaData(fileName));
        end
    end

    methods (Access = private)

        function metaData = extractFileMetaData(this, fileName)
        % EXTRACTMETADATA Extract meta data information from file name.

            rawData = regexp(fileName, this.FileNamePattern, "names");

            timestamp = datetime(rawData.date + rawData.time, InputFormat = "yyyyMMddHHmmss", TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format);
            metaData = mag.meta.HK(Type = rawData.type, Timestamp = timestamp);
        end
    end
end
