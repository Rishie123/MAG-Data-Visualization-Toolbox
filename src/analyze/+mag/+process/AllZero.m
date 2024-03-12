classdef AllZero < mag.process.Step
% ALLZERO Remove vectors where timestamp and data is all zero.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % VARIABLES Variables to check for all-zero.
        Variables (1, :) string
    end

    methods

        function this = AllZero(options)

            arguments
                options.?mag.process.AllZero
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "All-Zero";
        end

        function value = get.Description(~)
            value = "Remove vectors where timestamp and data is all zero.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description;
        end

        function data = apply(this, data, ~)

            arguments
                this (1, 1) mag.process.AllZero
                data tabular
                ~
            end

            locData = all(data{:, this.Variables} == 0, 2);
            data(locData, :) = [];
        end
    end
end
