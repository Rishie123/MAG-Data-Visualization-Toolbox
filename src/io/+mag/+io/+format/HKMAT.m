classdef HKMAT < mag.io.format.Data
% HKMAT Format HK data for MAT import/export.

    methods

        function exportedData = formatForExport(this, data, metaData)

            arguments
                this
                data (1, :) cell
                metaData (1, :) mag.meta.HK
            end

            exportedData = struct();

            exportedData = this.addHKData(exportedData, data, metaData, "PWR", "PW");
            exportedData = this.addHKData(exportedData, data, metaData, "SID15");
            exportedData = this.addHKData(exportedData, data, metaData, "STATUS");
        end
    end

    methods (Static, Access = private)

        function exportedData = addHKData(exportedData, data, metaData, matTypeName, dataTypeName)

            arguments
                exportedData (1, 1) struct
                data (1, :) cell
                metaData (1, :) mag.meta.HK
                matTypeName (1, 1) string
                dataTypeName (1, 1) string = matTypeName
            end

            selectedData = data{[metaData.Type] == dataTypeName};
            exportedData.HK.(matTypeName).Time = selectedData.t;

            for p = string(selectedData.Properties.VariableNames)

                if (~isequal(p, "t") && ~isequal(p, "timestamp"))
                    exportedData.HK.(matTypeName).(p) = selectedData.(p);
                end
            end
        end
    end
end
