classdef Ramp < mag.process.Step
% RAMP Isolate and validate ramp mode.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties (Constant)
        % PATTERN Pattern to be matched by ramp.
        Pattern (1, 8) double = [2, 2, 2, 2, 2, 2, 2, 1]
    end

    methods

        function value = get.Name(~)
            value = "Validate Ramp Mode";
        end

        function value = get.Description(~)
            value = "Validate that ramp mode derivative meets the expected pattern.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description;
        end

        function data = apply(this, data, ~)

            arguments
                this
                data
                ~
            end

            % Verify that no data is dropped during ramp mode.
            for d = ["dx", "dy", "dz"]

                diff = data.(d)';
                matches = strfind(diff, this.Pattern);

                if numel(matches) < floor((numel(diff) - 1) / numel(this.Pattern))
                    warning("Ramp pattern inconsistent along %s-axis.", extractAfter(d, "d"));
                end
            end
        end
    end
end
