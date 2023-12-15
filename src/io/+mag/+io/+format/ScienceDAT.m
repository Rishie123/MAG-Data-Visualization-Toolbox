classdef ScienceDAT < mag.io.format.Data
% SCIENCEDAT Format science data for DATA import/export.

    methods

        function exportedData = formatForExport(~, data, ~)

            arguments
                ~
                data (1, 2) cell
                ~
            end

            exportedData = data;
        end
    end
end
