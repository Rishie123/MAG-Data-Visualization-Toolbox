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

        % Test that "crop" method does not fail when no data is selected.
        function cropMethod_noSelection(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise.
            data.crop(timerange(datetime("Inf", TimeZone = "local"), datetime("-Inf", TimeZone = "local")));

            % Verify.
            testCase.verifyEmpty(data.IndependentVariable, "All data should be cropped out.");
            testCase.verifyEmpty(data.DependentVariables, "All data should be cropped out.");

            testCase.verifyTrue(ismissing(data.MetaData.Timestamp), "All data should be cropped out.");
        end

        % Test that "resample" method can resample to a lower frequency.
        function resampleMethod_lowerFrequency(testCase)

            % Set up.
            data = testCase.createTestData();

            initialFrequency = 1 / seconds(mode(data.dT));

            % Exercise.
            resampledData = data.copy();
            resampledData.resample(initialFrequency / 2);

            % Verify.
            testCase.assertEqual(height(resampledData.IndependentVariable), height(data.Time) / 2, "Frequency should be halved.");
            testCase.verifyEqual(resampledData.Time, (data.Time(1):minutes(2):data.Time(end))', "Frequency should be halved.");

            testCase.assertEqual(height(resampledData.DependentVariables), height(data.DependentVariables) / 2, "Frequency should be halved.");
        end

        % Test that "resample" method can resample to a higher frequency.
        function resampleMethod_higherFrequency(testCase)

            % Set up.
            data = testCase.createTestData();

            initialFrequency = 1 / seconds(mode(data.dT));

            % Exercise.
            resampledData = data.copy();
            resampledData.resample(2 * initialFrequency);

            % Verify.
            testCase.assertEqual(height(resampledData.IndependentVariable), (2 * height(data.Time)) - 1, "Frequency should be doubled.");
            testCase.verifyEqual(resampledData.Time, (data.Time(1):seconds(30):data.Time(end))', "Frequency should be doubled.");

            testCase.assertEqual(height(resampledData.DependentVariables), (2 * height(data.DependentVariables)) - 1, "Frequency should be doubled.");
        end

        % Test that "resample" method throws when target frequency is not
        % compatible with initial frequency.
        function resampleMethod_error(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise and verify.
            testCase.verifyError(@() data.resample(0.12345), "", "Resampling should error when frequencies do not match.");
        end

        % Test that "downsample" method can downsample to a lower frequency.
        function downsampleMethod_lowerFrequency(testCase)

            % Set up.
            data = testCase.createTestData();

            initialFrequency = 1 / seconds(mode(data.dT));

            % Exercise.
            downsampledData = data.copy();
            downsampledData.downsample(initialFrequency / 2);

            % Verify.
            testCase.assertEqual(height(downsampledData.IndependentVariable), height(data.Time) / 2, "Frequency should be halved.");
            testCase.verifyEqual(downsampledData.Time, (data.Time(1):minutes(2):data.Time(end))', "Frequency should be halved.");

            testCase.assertEqual(height(downsampledData.DependentVariables), height(data.DependentVariables) / 2, "Frequency should be halved.");
            testCase.verifyTrue(any(ismissing(downsampledData.XYZ), "all"), "Initial data should be replaced with missing values to account for filter warm-up.");
        end

        % Test that "downsample" method throws when target frequency is not
        % compatible with initial frequency.
        function downsampleMethod_error(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise and verify.
            testCase.verifyError(@() data.downsample(0.12345), "", "Resampling should error when frequencies do not match.");
        end

        % Test that "filter" method can filter with a "digitalFilter"
        % object.
        function filterMethod_digitalFilter(testCase)

            % Set up.
            data = testCase.createTestData();

            initialFrequency = 1 / seconds(mode(data.dT));
            filter = designfilt("lowpassfir", SampleRate = initialFrequency, PassbandFrequency = (initialFrequency / 4), StopbandFrequency = 1.5 * (initialFrequency / 4));

            % Exercise.
            downsampledData = data.copy();
            downsampledData.filter(filter);

            % Verify.
            testCase.assertSize(downsampledData.IndependentVariable, size(data.Time), "Filtering should not affect size.");
            testCase.verifyEqual(downsampledData.Time, data.Time, "Filtering should not affect time.");

            testCase.assertSize(downsampledData.DependentVariables, size(data.DependentVariables), "Filtering should not affect size.");
            testCase.verifyTrue(all(ismissing(downsampledData.XYZ), "all"), "All data should be replaced with missing values to account for filter warm-up.");
        end
    end

    methods (Access = private)

        function cropAndVerify(testCase, data, timeFilter, expectedTimes, expectedData)

            % Exercise.
            data.crop(timeFilter);

            % Verify.
            testCase.assertSize(data.IndependentVariable, size(expectedTimes), "Data should be cropped as expected.");
            testCase.verifyEqual(data.Time, expectedTimes, "Data should be cropped as expected.");

            testCase.assertSize(data.DependentVariables, size(expectedData), "Data should be cropped as expected.");
            testCase.verifyEqual(data.DependentVariables, expectedData, "Data should be cropped as expected.");

            testCase.verifyEqual(data.MetaData.Timestamp, data.Time(1), "Meta data timestamp should be updated.");
        end
    end

    methods (Static, Access = private)

        function [data, rawData] = createTestData()

            rawData = timetable(datetime("now", TimeZone = "UTC") + minutes(1:10)', (1:10)', (11:20)', (21:30)', 3 * ones(10, 1), (1:10)', VariableNames = ["x", "y", "z", "range", "sequence"]);
            data = mag.Science(rawData, mag.meta.Science(Timestamp = datetime("now", TimeZone = "UTC")));
        end
    end
end
