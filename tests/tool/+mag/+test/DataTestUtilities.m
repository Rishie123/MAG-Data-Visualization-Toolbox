classdef DataTestUtilities
% DATATESTUTILITIES Utilities for data tests.

    properties (Constant)
        % TIME Definition of timetable time.
        Time (:, 1) datetime = datetime("today", TimeZone = "UTC") + minutes(1:10)'
    end

    methods (Static)

        function scienceTT = getScienceTimetable()
        % GETSCIENCETIMETABLE Get timetable of science data.

            scienceTT = timetable(mag.test.DataTestUtilities.Time, (1:10)', (11:20)', (21:30)', 3 * ones(10, 1), (1:10)', repmat(mag.meta.Quality.Regular, 10, 1), ...
                VariableNames = ["x", "y", "z", "range", "sequence", "quality"]);
            scienceTT.Properties.VariableContinuity = ["continuous", "continuous", "continuous", "step", "step", "event"];
        end
    end
end
