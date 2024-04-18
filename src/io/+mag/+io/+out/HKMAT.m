classdef HKMAT < mag.io.out.MAT
% HKMAT Format HK data for MAT export.

    methods

        function fileName = getExportFileName(~, data)

            arguments
                ~
                data (1, :) mag.HK
            end

            metaData = [data.MetaData];
            fileName = compose("%s HK", datestr(min([metaData.Timestamp]), "ddmmyy-hhMM")) + ".mat"; %#ok<DATST>
        end

        function structData = convertToStruct(this, data)

            arguments
                this
                data (1, :) mag.HK
            end

            structData = struct();

            structData = this.addHKData(structData, data.getHKType("PW"), "PWR");
            structData = this.addHKData(structData, data.getHKType("SID15"), "SID15");
            structData = this.addHKData(structData, data.getHKType("STATUS"), "STATUS");
            structData = this.addHKData(structData, data.getHKType("PROCSTAT"), "PROCSTAT");
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
