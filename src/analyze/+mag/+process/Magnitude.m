classdef Magnitude < mag.process.Step
% MAGNITUDE Compute magnitude of 3-axis components.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % VARIABLES Variables to compute magnitude for.
        Variables (1, :) string = ["x", "y", "z"]
    end

    methods

        function this = Magnitude(options)

            arguments
                options.?mag.process.Magnitude
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Compute Magnitude";
        end

        function value = get.Description(this)
            value = "Compute magnitude of " + join(compose("""%s""", this.Variables), ", ") + " variables.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description;
        end

        function data = apply(this, data, ~)
            data.B = this.computeMagnitude(data{:, this.Variables});
        end
    end

    methods (Hidden)

        function magnitude = computeMagnitude(~, data)

            arguments (Input)
                ~
                data (:, 3) double
            end

            arguments (Output)
                magnitude (:, 1) double
            end

            magnitude = vecnorm(data, 2, 2);
        end
    end
end
