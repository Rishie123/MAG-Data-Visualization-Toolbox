classdef ScienceMAT < mag.io.format.Data
% SCIENCEMAT Format science data for MAT import/export.

    methods

        function exportedData = formatForExport(~, data, metaData)

            arguments
                ~
                data (1, 2) cell
                metaData (1, 2) mag.meta.Science
            end

            exportedData.B.P.Time = data{1}.t;
            exportedData.B.P.Data = [data{1}.x, data{1}.y, data{1}.z];
            exportedData.B.P.Range = data{1}.range;
            exportedData.B.P.Sequence = data{1}.sequence;
            exportedData.B.P.MetaData = struct(metaData(1));

            exportedData.B.S.Time = data{2}.t;
            exportedData.B.S.Data = [data{2}.x, data{2}.y, data{2}.z];
            exportedData.B.S.Range = data{2}.range;
            exportedData.B.S.Sequence = data{2}.sequence;
            exportedData.B.S.MetaData = struct(metaData(2));
        end
    end
end
