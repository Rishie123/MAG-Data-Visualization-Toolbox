classdef (Abstract) Type < mag.mixin.SetGet
% TYPE Import/Export type for MAG science and HK data.

    properties (Abstract, Constant)
        % EXTENSION Extension supported for file format.
        Extension (1, 1) string
    end

    properties
        % IMPORTFILENAMES One or more files to import.
        ImportFileNames (1, :) string {mustBeFile}
        % EXPORTFILENAME File to export to.
        ExportFileName (1, 1) string
    end

    methods (Abstract)

        % IMPORT Import data from one or more files.
        data = import(this, options)

        % EXPORT Export data to a file.
        export(this, data, options)
    end
end
