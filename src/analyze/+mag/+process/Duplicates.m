classdef Duplicates < mag.process.Step
% DUPLICATES Remove duplicate timestamps.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties (SetAccess = private)
        % DUPLICATETIMESTAMPS Counter for number of duplicate timestamps.
        DuplicateTimeStamps (1, 1) double = 0
    end

    methods

        function value = get.Name(~)
            value = "Remove Duplicate Timestamps";
        end

        function value = get.Description(~)
            value = "Remove duplicate timestamps.";
        end

        function value = get.DetailedDescription(this)

            value = this.Description + " Only the first timestamp is kept. " + ...
                this.DuplicateTimeStamps + " were removed during this processing session.";
        end

        function data = apply(this, data, ~)

            arguments
                this
                data timetable
                ~
            end

            time = data.(data.Properties.DimensionNames{1});
            locDuplicates = diff(time) == 0;

            if any(locDuplicates)

                this.DuplicateTimeStamps = this.DuplicateTimeStamps + nnz(locDuplicates);
                warning("%d duplicate timestamps.", nnz(locDuplicates));

                data(locDuplicates, :) = [];
            end
        end
    end
end
