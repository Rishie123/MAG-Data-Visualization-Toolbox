classdef Missing < mag.process.Step
% MISSING Remove rows where all the values in the columns of interest are
% missing.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % VARIABLES Variables to be used as reference to detect missing
        % values.
        Variables (1, :) string
    end

    methods

        function this = Missing(options)

            arguments
                options.?mag.process.Missing
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Remove Missing Data";
        end

        function value = get.Description(this)
            value = "Remove rows whose variables " + join(compose("""%s""", this.Variables), ", ") + " are all missing.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description + " Examples of missing values are: ""NaN"", ""NaT"", etc.";
        end

        function data = apply(this, data, ~)
            data = rmmissing(data, DataVariables = this.Variables, MinNumMissing = numel(this.Variables));
        end
    end
end
