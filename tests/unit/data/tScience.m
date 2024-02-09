classdef tScience < matlab.unittest.TestCase
% TSCIENCE Unit tests for "mag.Science" class.

    properties (TestParameter)
        DerivativeVariable = {"dX", "dY", "dZ"}
    end

    methods (Test)

        % Test that science meta data restricts setting "Model" value.
        function metadata_model(testCase)

            % Set up.
            metaData = mag.meta.Science();

            % Exercise and verify.
            testCase.verifyError(@() set(metaData, "Model", "AM2"), ?MException, "Error should be thrown when model name is invalid.");
        end

        % Test that science meta data restricts setting "FEE" value.
        function metadata_fee(testCase)

            % Set up.
            metaData = mag.meta.Science();

            % Exercise and verify.
            testCase.verifyError(@() set(metaData, "FEE", "FAA2"), ?MException, "Error should be thrown when FEE name is invalid.");
        end

        % Test that magnetic field magnitude is computed correctly.
        function magnitude(testCase)

            % Set up.
            science = testCase.createTestData();

            expectedMagnitude = sqrt(sum([science.X.^2, science.Y.^2, science.Z.^2], 2));

            % Exercise.
            actualMagnitude = science.B;

            % Verify.
            testCase.verifyThat(actualMagnitude, matlab.unittest.constraints.IsEqualTo(expectedMagnitude, Within = matlab.unittest.constraints.AbsoluteTolerance(1e-12)), ...
                "Magnitude should have expected values.");
        end

        % Test that derivative of an empty value is itself empty.
        function derivative_empty(testCase, DerivativeVariable)

            % Set up.
            science = testCase.createEmptyTestData();

            % Exercise.
            derivative = science.(DerivativeVariable);

            % Verify.
            testCase.verifyEmpty(derivative, "Derivative of empty value should itself be empty.");
        end

        % Test that derivative of a value is correct.
        function derivative_nonEmpty(testCase, DerivativeVariable)

            % Set up.
            science = testCase.createTestData();

            v = erase(DerivativeVariable, "d");
            expectedDerivative = diff(science.(v));

            % Exercise.
            actualDerivative = science.(DerivativeVariable);

            % Verify.
            testCase.verifyEqual(actualDerivative(1:end-1), expectedDerivative, "Derivative should match expected value.");
            testCase.verifyTrue(ismissing(actualDerivative(end)), "Last element in derivative should be missing.");
        end

        % Test that "crop" method crops data based on a "duration" object.
        function cropMethod_duration(testCase)

            % Set up.
            science = testCase.createTestData();

            expectedTimes = science.Time(2:end);
            expectedData = science.DependentVariables(2:end, :);

            timeFilter = minutes(1);

            % Exercise and verify.
            testCase.cropAndVerify(science, timeFilter, expectedTimes, expectedData);
        end

        % Test that "crop" method crops data based on a "timerange" object.
        function cropMethod_timerange(testCase)

            % Set up.
            science = testCase.createTestData();

            expectedTimes = science.Time(3:end);
            expectedData = science.DependentVariables(3:end, :);

            timeFilter = timerange(science.Time(2), science.Time(end), "openleft");

            % Exercise and verify.
            testCase.cropAndVerify(science, timeFilter, expectedTimes, expectedData);
        end

        % Test that "crop" method crops data based on a "withtol" object.
        function cropMethod_withtol(testCase)

            % Set up.
            science = testCase.createTestData();

            expectedTimes = science.Time(4:6);
            expectedData = science.DependentVariables(4:6, :);

            timeFilter = withtol(science.Time(5), minutes(1));

            % Exercise and verify.
            testCase.cropAndVerify(science, timeFilter, expectedTimes, expectedData);
        end

        % Test that "crop" method also crops events.
        function cropMethod_events(testCase)

            % Set up.
            science = testCase.createTestData();
            science.Data.Properties.Events = eventtable(science.Data);

            % Exercise.
            science.crop(minutes(1));

            % Verify.
            testCase.assertEqual(height(science.Events.Time), height(science.Time), "Data should be cropped as expected.");
            testCase.verifyEqual(science.Events.Time, science.Time, "Data should be cropped as expected.");
        end

        % Test that "crop" method does not fail when no data is selected.
        function cropMethod_noSelection(testCase)

            % Set up.
            science = testCase.createTestData();

            % Exercise.
            science.crop(timerange(datetime("Inf", TimeZone = "local"), datetime("-Inf", TimeZone = "local")));

            % Verify.
            testCase.verifyEmpty(science.IndependentVariable, "All data should be cropped out.");
            testCase.verifyEmpty(science.DependentVariables, "All data should be cropped out.");

            testCase.verifyTrue(ismissing(science.MetaData.Timestamp), "All data should be cropped out.");
        end

        % Test that "resample" method can resample to a lower frequency.
        function resampleMethod_lowerFrequency(testCase)

            % Set up.
            science = testCase.createTestData();

            initialFrequency = 1 / seconds(mode(science.dT));

            % Exercise.
            resampledData = science.copy();
            resampledData.resample(initialFrequency / 2);

            % Verify.
            testCase.assertEqual(height(resampledData.IndependentVariable), height(science.Time) / 2, "Frequency should be halved.");
            testCase.verifyEqual(resampledData.Time, (science.Time(1):minutes(2):science.Time(end))', "Frequency should be halved.");

            testCase.assertEqual(height(resampledData.DependentVariables), height(science.DependentVariables) / 2, "Frequency should be halved.");
        end

        % Test that "resample" method can resample to a higher frequency.
        function resampleMethod_higherFrequency(testCase)

            % Set up.
            science = testCase.createTestData();

            initialFrequency = 1 / seconds(mode(science.dT));

            % Exercise.
            resampledData = science.copy();
            resampledData.resample(2 * initialFrequency);

            % Verify.
            testCase.assertEqual(height(resampledData.IndependentVariable), (2 * height(science.Time)) - 1, "Frequency should be doubled.");
            testCase.verifyEqual(resampledData.Time, (science.Time(1):seconds(30):science.Time(end))', "Frequency should be doubled.");

            testCase.assertEqual(height(resampledData.DependentVariables), (2 * height(science.DependentVariables)) - 1, "Frequency should be doubled.");
        end

        % Test that "resample" method throws when target frequency is not
        % compatible with initial frequency.
        function resampleMethod_error(testCase)

            % Set up.
            science = testCase.createTestData();

            % Exercise and verify.
            testCase.verifyError(@() science.resample(0.12345), "", "Resampling should error when frequencies do not match.");
        end

        % Test that "downsample" method can downsample to a lower frequency.
        function downsampleMethod_lowerFrequency(testCase)

            % Set up.
            science = testCase.createTestData();

            initialFrequency = 1 / seconds(mode(science.dT));

            % Exercise.
            downsampledData = science.copy();
            downsampledData.downsample(initialFrequency / 2);

            % Verify.
            testCase.assertEqual(height(downsampledData.IndependentVariable), height(science.Time) / 2, "Frequency should be halved.");
            testCase.verifyEqual(downsampledData.Time, (science.Time(1):minutes(2):science.Time(end))', "Frequency should be halved.");

            testCase.assertEqual(height(downsampledData.DependentVariables), height(science.DependentVariables) / 2, "Frequency should be halved.");
            testCase.verifyTrue(any(ismissing(downsampledData.XYZ), "all"), "Initial data should be replaced with missing values to account for filter warm-up.");
        end

        % Test that "downsample" method throws when target frequency is not
        % compatible with initial frequency.
        function downsampleMethod_error(testCase)

            % Set up.
            science = testCase.createTestData();

            % Exercise and verify.
            testCase.verifyError(@() science.downsample(0.12345), "", "Resampling should error when frequencies do not match.");
        end

        % Test that "filter" method can filter with a "digitalFilter"
        % object.
        function filterMethod_digitalFilter(testCase)

            % Set up.
            science = testCase.createTestData();

            initialFrequency = 1 / seconds(mode(science.dT));
            filter = designfilt("lowpassfir", SampleRate = initialFrequency, PassbandFrequency = (initialFrequency / 4), StopbandFrequency = 1.5 * (initialFrequency / 4));

            % Exercise.
            downsampledScience = science.copy();
            downsampledScience.filter(filter);

            % Verify.
            testCase.assertSize(downsampledScience.IndependentVariable, size(science.Time), "Filtering should not affect size.");
            testCase.verifyEqual(downsampledScience.Time, science.Time, "Filtering should not affect time.");

            testCase.assertSize(downsampledScience.DependentVariables, size(science.DependentVariables), "Filtering should not affect size.");
            testCase.verifyTrue(all(ismissing(downsampledScience.XYZ), "all"), "All data should be replaced with missing values to account for filter warm-up.");
        end

        % Test that "replace" method replaces data with default filler.
        function replaceMethod_default(testCase)

            % Set up.
            science = testCase.createTestData();

            % Exercise.
            modifiedScience = science.copy();
            modifiedScience.replace(minutes(3));

            % Verify.
            testCase.assertSize(modifiedScience.IndependentVariable, size(science.Time), "Time should not be modified.");
            testCase.verifyEqual(modifiedScience.Time, science.Time, "Time should not be modified.");

            testCase.assertSize(modifiedScience.DependentVariables, size(science.DependentVariables), "Data size should not change.");
            testCase.verifyTrue(all(ismissing(modifiedScience.XYZ(1:4, :)), "all"), "Data within filter should be replaced.");
            testCase.verifyEqual(modifiedScience.DependentVariables(5:end, :), science.DependentVariables(5:end, :), "Only data within filter should be replaced.");
        end

        % Test that "replace" method replaces data with default filler.
        function replaceMethod_specified(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise.
            modifiedScience = data.copy();
            modifiedScience.replace(minutes(3), 0);

            % Verify.
            testCase.assertSize(modifiedScience.IndependentVariable, size(data.Time), "Time should not be modified.");
            testCase.verifyEqual(modifiedScience.Time, data.Time, "Time should not be modified.");

            testCase.assertSize(modifiedScience.DependentVariables, size(data.DependentVariables), "Data size should not change.");
            testCase.verifyEqual(modifiedScience.XYZ(1:4, :), zeros(4, 3), "Data within filter should be replaced.");
            testCase.verifyEqual(modifiedScience.DependentVariables(5:end, :), data.DependentVariables(5:end, :), "Only data within filter should be replaced.");
        end

        % Test that PSD can detect sine wave frequency, with default
        % options.
        function computePSD_sineWave_default(testCase)

            % Set up.
            science = testCase.createSineWaveTestData();

            % Execute.
            psd = science.computePSD();

            % Verify.
            [~, idxMax] = max([psd.X, psd.Y, psd.Z]);

            testCase.verifyEqual(psd.Frequency(idxMax), [50; 100; 150], "PSD max frequency should match sine wave frequency.");
        end

        % Test that PSD can detect sine wave frequency, with selected data
        % only.
        function computePSD_sineWave_startAndDuration(testCase)

            % Set up.
            science = testCase.createSineWaveTestData();

            % Execute.
            psd = science.computePSD(Start = science.Time(10), Duration = milliseconds(500));

            % Verify.
            [~, idxMax] = max([psd.X, psd.Y, psd.Z]);

            testCase.verifyThat(psd.Frequency(idxMax), matlab.unittest.constraints.IsEqualTo([50; 100; 150], Within = matlab.unittest.constraints.RelativeTolerance(0.1)), ...
                "PSD max frequency should match sine wave frequency.");
        end

        % Test that displaying a single object displays the correct
        % information.
        function customDisplay_singleObject(testCase)

            % Set up.
            science = testCase.createTestData();

            science.MetaData.DataFrequency = 64;
            science.MetaData.Mode = "Burst";
            science.MetaData.Model = "FM4";
            science.MetaData.Sensor = "FIB";

            % Exercise.
            output = evalc("display(science)");

            % Verify.
            testCase.verifySubstring(eraseTags(output), "FIB (FM4) in Burst (64)", "Science meta data should be included in display.");
        end

        % Test that displaying a single object displays the correct
        % information, even when model is missing.
        function customDisplay_singleObject_noModel(testCase)

            % Set up.
            science = testCase.createTestData();

            science.MetaData.DataFrequency = 64;
            science.MetaData.Mode = "Burst";
            science.MetaData.Model = string.empty();
            science.MetaData.Sensor = "FIB";

            % Exercise.
            output = evalc("display(science)");

            % Verify.
            testCase.verifySubstring(eraseTags(output), "FIB in Burst (64)", "Science meta data should be included in display.");
        end

        % Test that displaying a single object displays the correct
        % information, even when model and sensor are missing.
        function customDisplay_singleObject_noSensor(testCase)

            % Set up.
            science = testCase.createTestData();

            science.MetaData.DataFrequency = 64;
            science.MetaData.Mode = "Burst";
            science.MetaData.Model = string.empty();
            science.MetaData.Sensor = mag.meta.Sensor.empty();

            % Exercise.
            output = evalc("display(science)");

            % Verify.
            testCase.verifySubstring(eraseTags(output), "in Burst (64)", "Science meta data should be included in display.");
        end

        % Test that displaying heterogeneous arrays does not error.
        function customDisplay_heterogeneous(testCase)

            % Set up.
            science = testCase.createTestData();
            science = [science, science]; %#ok<NASGU>

            % Exercise and verify.
            evalc("display(science)");
        end
    end

    methods (Access = private)

        function cropAndVerify(testCase, science, timeFilter, expectedTimes, expectedData)

            % Exercise.
            science.crop(timeFilter);

            % Verify.
            testCase.assertSize(science.IndependentVariable, size(expectedTimes), "Data should be cropped as expected.");
            testCase.verifyEqual(science.Time, expectedTimes, "Data should be cropped as expected.");

            testCase.assertSize(science.DependentVariables, size(expectedData), "Data should be cropped as expected.");
            testCase.verifyEqual(science.DependentVariables, expectedData, "Data should be cropped as expected.");

            testCase.verifyEqual(science.MetaData.Timestamp, science.Time(1), "Meta data timestamp should be updated.");
        end
    end

    methods (Static, Access = private)

        function [science, rawData] = createEmptyTestData()

            emptyTime = datetime.empty();
            emptyTime.TimeZone = "UTC";

            rawData = struct2table(struct(Time = emptyTime, ...
                x = double.empty(0, 1), ...
                y = double.empty(0, 1), ...
                z = double.empty(0, 1), ...
                range = double.empty(0, 1), ...
                sequence = double.empty(0, 1)));
            rawData = table2timetable(rawData, RowTimes = "Time");

            science = mag.Science(rawData, mag.meta.Science(Timestamp = datetime("now", TimeZone = "UTC")));
        end

        function [science, rawData] = createTestData()

            rawData = timetable(datetime("now", TimeZone = "UTC") + minutes(1:10)', (1:10)', (11:20)', (21:30)', 3 * ones(10, 1), (1:10)', VariableNames = ["x", "y", "z", "range", "sequence"]);
            science = mag.Science(rawData, mag.meta.Science(Timestamp = datetime("now", TimeZone = "UTC")));
        end

        function [science, rawData] = createSineWaveTestData()

            num = 1000;

            timestamp = datetime("now", TimeZone = "UTC") + milliseconds(1:num)';

            t = seconds(timestamp - timestamp(1));
            x = sin(100 * pi * t);
            y = sin(200 * pi * t);
            z = sin(300 * pi * t);

            rawData = timetable(timestamp, x, y, z, 3 * ones(num, 1), (1:num)', VariableNames = ["x", "y", "z", "range", "sequence"]);
            science = mag.Science(rawData, mag.meta.Science(Timestamp = datetime("now", TimeZone = "UTC")));
        end
    end
end
