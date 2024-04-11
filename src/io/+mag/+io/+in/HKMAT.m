classdef HKMAT < mag.io.in.IMAT
% HKMAT Format HK data for MAT import.

    methods

        function data = convertFromStruct(~, structData) %#ok<STOUT,INUSD>
            error("Unsupported import from MAT.");
        end
    end
end
