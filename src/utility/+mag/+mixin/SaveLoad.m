classdef (Abstract, HandleCompatible) SaveLoad
% SAVELOAD Utility class to aid saving and loading to MAT files.

    properties (Abstract, Constant)
        % VERSION Version number.
        Version (1, 1) string
    end

    properties (GetAccess = protected, SetAccess = private)
        % ORIGINALVERSION Original version for save/load compatibility.
        OriginalVersion (1, 1) string
    end

    methods (Hidden)

        function savedObject = saveobj(this)
            
            savedObject = this;
            savedObject.OriginalVersion = this.Version;
        end
    end
end