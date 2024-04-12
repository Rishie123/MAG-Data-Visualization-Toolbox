classdef (Abstract) Format < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% IFORMAT Interface for data format providers for export.

    methods (Abstract)

        % GETEXPORTFILENAME Get name of export file name.
        fileName = getExportFileName(this, inputFileName, data)
    end
end
