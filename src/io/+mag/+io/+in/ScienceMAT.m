classdef ScienceMAT < mag.io.in.MAT
% SCIENCEMAT Format science data for MAT import.

    methods

        function data = convertFromStruct(~, structData) %#ok<STOUT,INUSD>
            error("Unsupported import from MAT.");
        end
    end
end
