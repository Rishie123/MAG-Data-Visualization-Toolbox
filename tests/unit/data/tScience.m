classdef tScience < matlab.unittest.TestCase
% TSCIENCE Unit tests for "mag.Science" class.

    methods (Test)

        % Test that "crop" method crops data based on a "duration" object.
        function cropMethod_duration(testCase)

            % Set up.
            data = testCase.createTestData();

            expectedTimes = data.Time(2:end);
            expectedData = data.DependentVariables(2:end, :);

            timeFilter = minutes(1);

            % Exercise and verify.
            testCase.cropAndVerify(data, timeFilter, expectedTimes, expectedData);
        end

        % Test that "crop" method crops data based on a "timerange" object.
        function cropMethod_timerange(testCase)

            % Set up.
            data = testCase.createTestData();

            expectedTimes = data.Time(3:end);
            expectedData = data.DependentVariables(3:end, :);

            timeFilter = timerange(data.Time(2), data.Time(end), "openleft");

            % Exercise and verify.
            testCase.cropAndVerify(data, timeFilter, expectedTimes, expectedData);
        end

        % Test that "crop" method crops data based on a "withtol" object.
        function cropMethod_withtol(testCase)

            % Set up.
            data = testCase.createTestData();

            expectedTimes = data.Time(4:6);
            expectedData = data.DependentVariables(4:6, :);

            timeFilter = withtol(data.Time(5), minutes(1));

            % Exercise and verify.
            testCase.cropAndVerify(data, timeFilter, expectedTimes, expectedData);
        end

        % Test that "crop" method also crops events.
        function cropMethod_events(testCase)

            % Set up.
            data = testCase.createTestData();
            data.Data.Properties.Events = eventtable(data.Data);

            % Exercise.
            data.crop(minutes(1));

            % Verify.
            testCase.assertEqual(height(data.Events.Time), height(data.Time), "Data should be cropped as expected.");
            testCase.verifyEqual(data.Events.Time, data.Time, "Data should be cropped as expected.");
        end
    end

    methods (Access = private)

        function cropAndVerify(testCase, data, timeFilter, expectedTimes, expectedData)

            % Exercise.
            data.crop(timeFilter);

            % Verify.
            testCase.assertEqual(height(data.IndependentVariable), height(expectedTimes), "Data should be cropped as expected.");
            testCase.verifyEqual(data.Time, expectedTimes, "Data should be cropped as expected.");

            testCase.assertEqual(height(data.DependentVariables), height(expectedData), "Data should be cropped as expected.");
            testCase.verifyEqual(data.DependentVariables, expectedData, "Data should be cropped as expected.");

            testCase.verifyEqual(data.MetaData.Timestamp, data.Time(1), "Meta data timestamp should be updated.");
        end
    end

    methods (Static, Access = private)

        function [data, rawData] = createTestData()

            rawData = timetable(datetime("now", TimeZone = "UTC") + minutes(1:10)', (1:10)', (11:20)', (21:30)', 3 * ones(10, 1), (1:10)', VariableNames = ["x", "y", "z", "range", "sequence"]);
            rawData.B = vecnorm(rawData{:, ["x", "y", "z"]}, 2, 2);

            data = mag.Science(rawData, mag.meta.Science());
        end
    end
end
