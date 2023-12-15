classdef Sort < mag.process.Step
% SORT Sort data cronologically.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    methods

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

        function data = apply(~, data, ~)

            arguments
                ~
                data timetable
                ~
            end

            data = sortrows(data, data.Properties.DimensionNames{1});
        end
    end
end
