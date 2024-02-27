classdef ScienceMAT < mag.io.format.Data
% SCIENCEMAT Format science data for MAT import/export.

    methods

        function exportedData = formatForExport(~, data)

            arguments
                ~
                data (1, 1) {mustBeA(data, ["mag.Instrument", "mag.IALiRT"])}
            end

            exportedData.B.P.Time = data.Primary.Time;
            exportedData.B.P.Data = data.Primary.XYZ;
            exportedData.B.P.Range = data.Primary.Range;
            exportedData.B.P.Sequence = data.Primary.Sequence;
            exportedData.B.P.Compression = data.Primary.Compression;
            exportedData.B.P.MetaData = struct(data.Primary.MetaData);

            exportedData.B.S.Time = data.Secondary.Time;
            exportedData.B.S.Data = data.Secondary.XYZ;
            exportedData.B.S.Range = data.Secondary.Range;
            exportedData.B.S.Sequence = data.Secondary.Sequence;
            exportedData.B.S.Compression = data.Secondary.Compression;
            exportedData.B.S.MetaData = struct(data.Secondary.MetaData);
        end
    end
end
