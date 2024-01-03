classdef (Abstract) MAGAnalysisTestCase < matlab.unittest.TestCase
% MAGANALYSISTESTCASE Base class for all MAG analysis tests.

    methods (Access = protected)

        function data = createTestData(~, options)

            arguments
                ~
                options.XYZ (:, 3) double = ones(3, 3)
                options.Range (:, 1) double = zeros(3, 1)
                options.Sequence (:, 1) double = [1; 2; 3]
            end

            time = [datetime("yesterday"), datetime("today"), datetime("now")];

            values = table(options.XYZ(:, 1), options.XYZ(:, 2), options.XYZ(:, 3), options.Range, options.Sequence, ...
                VariableNames = ["x", "y", "z", "range", "sequence"]);

            data = table2timetable(values, RowTimes = time);
        end
    end
end
