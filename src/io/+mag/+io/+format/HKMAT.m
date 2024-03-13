classdef HKMAT < mag.io.format.Data
% HKMAT Format HK data for MAT import/export.

    methods

        function exportedData = formatForExport(this, data)

            arguments
                this
                data (1, :) mag.HK
            end

            exportedData = struct();

            exportedData = this.addHKData(exportedData, data.getHKType("PW"), "PWR");
            exportedData = this.addHKData(exportedData, data.getHKType("SID15"), "SID15");
            exportedData = this.addHKData(exportedData, data.getHKType("STATUS"), "STATUS");
            exportedData = this.addHKData(exportedData, data.getHKType("PROCSTAT"), "PROCSTAT");
        end
    end

    methods (Static, Access = private)

        function exportedData = addHKData(exportedData, data, matTypeName)

            arguments
                exportedData (1, 1) struct
                data mag.HK {mustBeScalarOrEmpty}
                matTypeName (1, 1) string
            end

            if isempty(data)
                return;
            end

            exportedData.HK.(matTypeName).Time = data.Time;

            for p = string(data.Data.Properties.VariableNames)

                if (~isequal(p, "t") && ~isequal(p, "timestamp"))
                    exportedData.HK.(matTypeName).(p) = data.Data.(p);
                end
            end
        end
    end
end
