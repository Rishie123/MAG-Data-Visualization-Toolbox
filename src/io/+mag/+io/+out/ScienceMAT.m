classdef ScienceMAT < mag.io.out.IMAT
% SCIENCEMAT Format science data for MAT export.

    methods

        function fileName = getExportFileName(~, inputFileName, data)

            arguments
                ~
                inputFileName (1, 1) string
                data (1, 1) {mustBeA(data, ["mag.Instrument", "mag.IALiRT"])}
            end

            if ~isempty(inputFileName)
                fileName = options.FileName;
            else

                if data.MetaData.Mode == mag.meta.Mode.IALiRT
                    format = "%s %s (%.2f, %.2f)";
                else
                    format = "%s %s (%d, %d)";
                end

                fileName = fullfile(options.Location, compose(format, datestr(data.Primary.MetaData.Timestamp, "ddmmyy-hhMM"), ...
                    data.Primary.MetaData.Mode, data.Primary.MetaData.DataFrequency, data.Secondary.MetaData.DataFrequency) + ".mat"); %#ok<DATST>
            end
        end

        function structData = convertToStruct(~, data)

            arguments
                ~
                data (1, 1) {mustBeA(data, ["mag.Instrument", "mag.IALiRT"])}
            end

            structData.B.P.Time = data.Primary.Time;
            structData.B.P.Data = data.Primary.XYZ;
            structData.B.P.Range = data.Primary.Range;
            structData.B.P.Sequence = data.Primary.Sequence;
            structData.B.P.Compression = data.Primary.Compression;
            structData.B.P.MetaData = struct(data.Primary.MetaData);

            structData.B.S.Time = data.Secondary.Time;
            structData.B.S.Data = data.Secondary.XYZ;
            structData.B.S.Range = data.Secondary.Range;
            structData.B.S.Sequence = data.Secondary.Sequence;
            structData.B.S.Compression = data.Secondary.Compression;
            structData.B.S.MetaData = struct(data.Secondary.MetaData);
        end
    end
end
