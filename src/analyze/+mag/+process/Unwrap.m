classdef Unwrap < mag.process.Step
% UNWRAP Unwrap data based on integer limit provided.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % VARIABLES Variables to unwrap.
        Variables (1, :) string
        % INTEGERSIZE Size of integer to unwrap at.
        IntegerSize (1, 1) string {mustBeMember(IntegerSize, ["int8", "uint8", "int16", "uint16", "int32", "uint32", "int64", "uint64"])} = "int16"
        % TOLERANCE Tolerance for detection of where to wrap.
        Tolerance (1, 1) double = 100
    end

    methods

        function this = Unwrap(options)

            arguments
                options.?mag.process.Unwrap
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Unwrap Integers";
        end

        function value = get.Description(this)
            value = "Unwrap """ + this.IntegerSize + """ integer values by detecting when they reach saturation and restart counting.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description;
        end

        function data = apply(this, data, ~)

            arguments
                this
                data timetable
                ~
            end

            data{:, this.Variables} = unwrap(data{:, this.Variables}, double(intmax(this.IntegerSize)));
        end
    end
end
