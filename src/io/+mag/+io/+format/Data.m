classdef (Abstract) Data < mag.mixin.SetGet
% DATA Interface for data format providers for import/export.

    methods (Abstract)

        % FORMATFROMIMPORT Format imported data to "mag.Data".
        exportedData = formatFromImport(this, data)

        % FORMATFOREXPORT Format data ready for export.
        exportedData = formatForExport(this, data)
    end
end
