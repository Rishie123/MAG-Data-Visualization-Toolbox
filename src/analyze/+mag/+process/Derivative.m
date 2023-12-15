classdef Derivative < mag.process.Step
% DERIVATIVE Approximate derivative of variable with "diff".

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % VARIABLES Variables to compute derivative of.
        Variables (1, :) string
        % ORDER Derivative order.
        Order (1, 1) double = 1
        % PADDING Where padding should be added.
        Padding (1, 1) string {mustBeMember(Padding, ["pre", "post"])} = "post"
    end

    methods

        function this = Derivative(options)

            arguments
                options.?mag.process.Derivative
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Derivative Caluclation";
        end

        function value = get.Description(this)
            value = "Compute the derivative of " + join(compose("""%s""", this.Variables), ", ") + " variables.";
        end

        function value = get.DetailedDescription(this)

            value = this.Description + " Derivatives are stored as variables with the same name, " + ...
                "preceded by prefix ""d"".";
        end

        function data = apply(this, data, ~)

            arguments
                this
                data timetable
                ~
            end

            for v = this.Variables
                data.("d" + v) = padarray(diff(data.(v), this.Order), [this.Order, 0], NaN, this.Padding);
            end
        end
    end
end
