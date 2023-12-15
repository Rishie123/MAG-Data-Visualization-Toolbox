classdef SignedInteger < mag.process.Step
% SIGNEDINTEGER Convert data to signed int16, by using the first bit as
% indicating signedness.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    methods

        function value = get.Name(~)
            value = "Change Signedness";
        end

        function value = get.Description(~)
            value = "Convert data from unsigned to signed int16.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description + " The first bit is treated as indicating signedness.";
        end

        function data = apply(this, data, ~)
            data{:, ["x", "y", "z"]} = this.convertToSignedInteger(data{:, ["x", "y", "z"]});
        end
    end

    methods (Hidden)

        function signedData = convertToSignedInteger(this, unsignedData)

            arguments (Input)
                this
                unsignedData (:, :) double
            end

            arguments (Output)
                signedData (:, :) double
            end

            try
                signedData = this.doConvert(unsignedData);
            catch exception

                if isequal(exception.identifier, "MATLAB:bitget:outOfRange")
                    signedData = this.doConvert(unsignedData, "int16");
                else
                    exception.rethrow();
                end
            end
        end
    end

    methods (Static, Access = private)

        function signedData = doConvert(unsignedData, varargin)

            isNegative = bitget(unsignedData, 16, varargin{:});
            signedData = bitset(unsignedData, 16, 0, varargin{:}) + ((-2 ^ 15) * isNegative);
        end
    end
end
