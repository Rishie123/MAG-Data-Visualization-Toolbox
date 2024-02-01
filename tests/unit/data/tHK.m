classdef tHK < matlab.unittest.TestCase
% THK Unit tests for "mag.HK" class.

    methods (Test)

        % Test that "crop" method crops data based on a "timerange" object.
        function cropMethod_timerange(testCase)

            % Set up.
            data = testCase.createTestData();

            expectedTimes = {data(1).Time(3:end), data(2).Time(2:end)};
            expectedData = {data(1).DependentVariables(3:end, :), data(2).DependentVariables(2:end, :)};

            timeFilter = timerange(data(1).Time(2), data(1).Time(end), "openleft");

            % Exercise and verify.
            testCase.cropAndVerify(data, timeFilter, expectedTimes, expectedData);
        end

        % Test that "crop" method does not fail when no data is selected.
        function cropMethod_noSelection(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise.
            data.crop(timerange(datetime("Inf", TimeZone = "local"), datetime("-Inf", TimeZone = "local")));

            % Verify.
            for i = 1:numel(data)

                testCase.verifyEmpty(data(i).IndependentVariable, "All data should be cropped out.");
                testCase.verifyEmpty(data(i).DependentVariables, "All data should be cropped out.");

                testCase.verifyTrue(ismissing(data(i).MetaData.Timestamp), "All data should be cropped out.");
            end
        end

        % Test that "resample" method can resample to a higher frequency.
        function resampleMethod_higherFrequency(testCase)

            % Set up.
            data = testCase.createTestData();
            data = data(1);

            initialFrequency = 1 / seconds(mode(data.dT));

            % Exercise.
            resampledData = data.copy();
            resampledData.resample(2 * initialFrequency);

            % Verify.
            testCase.assertEqual(height(resampledData.IndependentVariable), (2 * height(data.Time)) - 1, "Frequency should be halved.");
            testCase.verifyEqual(resampledData.Time, (data.Time(1):seconds(30):data.Time(end))', "Frequency should be halved.");

            testCase.assertEqual(height(resampledData.DependentVariables), (2 * height(data.DependentVariables)) - 1, "Frequency should be halved.");
        end

        % Test that "downsample" method can resample to a lower frequency.
        function downsampleMethod_lowerFrequency(testCase)

            % Set up.
            data = testCase.createTestData();
            data = data(1);

            initialFrequency = 1 / seconds(mode(data.dT));

            % Exercise.
            resampledData = data.copy();
            resampledData.downsample(initialFrequency / 2);

            % Verify.
            testCase.assertEqual(height(resampledData.IndependentVariable), height(data.Time) / 2, "Frequency should be halved.");
            testCase.verifyEqual(resampledData.Time, (data.Time(1):minutes(2):data.Time(end))', "Frequency should be halved.");

            testCase.assertEqual(height(resampledData.DependentVariables), height(data.DependentVariables) / 2, "Frequency should be halved.");
        end

        % Test that "getHKType" method selects the correct type.
        function getHKType(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise.
            hk = data.getHKType("PROCSTAT");

            % Verify.
            testCase.verifyClass(hk, "mag.hk.Processor", "Correct type should be returned.");
        end
    end

    methods (Access = private)

        function cropAndVerify(testCase, data, timeFilter, expectedTimes, expectedData)

            % Exercise.
            data.crop(timeFilter);

            % Verify.
            for i = 1:numel(data)

                testCase.assertSize(data(i).IndependentVariable, size(expectedTimes{i}), "Data should be cropped as expected.");
                testCase.verifyEqual(data(i).Time, expectedTimes{i}, "Data should be cropped as expected.");

                testCase.assertSize(data(i).DependentVariables, size(expectedData{i}), "Data should be cropped as expected.");
                testCase.verifyEqual(data(i).DependentVariables, expectedData{i}, "Data should be cropped as expected.");

                testCase.verifyEqual(data(i).MetaData.Timestamp, data(i).Time(1), "Meta data timestamp should be updated.");
            end
        end
    end

    methods (Static, Access = private)

        function data = createTestData()

            timestamps = datetime("now", TimeZone = "UTC") + minutes(1:10)';

            statusData = timetable(timestamps, ones(10, 1), zeros(10, 1), VariableNames = ["FOBSTAT", "FIBSTAT"]);
            procstatData = timetable(timestamps(1:2:end), (1:5)', (11:15)', VariableNames = ["OBNQ_NUM_MSG", "IBNQ_NUM_MSG"]);

            data(1) = mag.hk.Status(statusData, mag.meta.HK(Type = "STATUS"));
            data(2) = mag.hk.Processor(procstatData, mag.meta.HK(Type = "PROCSTAT"));
        end
    end
end
