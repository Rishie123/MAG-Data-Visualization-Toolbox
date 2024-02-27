classdef Cast < mag.process.Step
% CAST Apply data type cast.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % DATATYPE Data type to convert to.
        DataType (1, 1) string
        % VARIABLES Variables to be cast.
        Variables (1, :) string
    end

    methods

        function this = Cast(options)

            arguments
                options.?mag.process.Cast
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Cast to Data Type";
        end

        function value = get.Description(this)
            value = "Cast " + join(compose("""%s""", this.Variables), ", ") + " to """ + this.DataType + """.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description;
        end

        function data = apply(this, data, ~)

            for v = this.Variables
                data.(v) = cast(data.(v), this.DataType);
            end
        end
    end
end
