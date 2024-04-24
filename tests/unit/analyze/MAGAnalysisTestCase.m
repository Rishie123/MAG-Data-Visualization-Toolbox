classdef (Abstract) MAGAnalysisTestCase < matlab.unittest.TestCase
% MAGANALYSISTESTCASE Base class for all MAG analysis tests.

    methods (Static, Access = protected)

        function data = createTestData(options)

            arguments
                options.Time (:, 1) datetime = [datetime("yesterday"), datetime("today"), datetime("now")]
                options.XYZ (:, 3) double = ones(3, 3)
                options.Range (:, 1) double = zeros(3, 1)
                options.Sequence (:, 1) double = [1; 2; 3]
            end

            values = table(options.XYZ(:, 1), options.XYZ(:, 2), options.XYZ(:, 3), options.Range, options.Sequence, ...
                VariableNames = ["x", "y", "z", "range", "sequence"]);

            data = table2timetable(values, RowTimes = options.Time);
        end
    end
end
