classdef Sort < mag.process.Step
% SORT Sort data cronologically.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % VARIABLES Variables to sort by.
        Variables (1, :) string = string.empty()
        % DIRECTION Sort direction.
        Direction (1, 1) string {mustBeMember(Direction, ["ascend", "descend"])} = "ascend"
    end

    methods

        function this = Sort(options)

            arguments
                options.?mag.process.Sort
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Sort Data";
        end

        function value = get.Description(~)
            value = "Sort data rows based on timestamp.";
        end

        function value = get.DetailedDescription(this)

            value = this.Description + " When importing data from multiple sources, data may not " + ...
                "be loaded chronologically. This step ensures data is chronological.";
        end

        function data = apply(this, data, ~)

            arguments
                this
                data tabular
                ~
            end

            if isempty(this.Variables)
                data = sortrows(data, data.Properties.DimensionNames{1}, this.Direction);
            else
                data = sortrows(data, this.Variables, this.Direction);
            end
        end
    end
end
