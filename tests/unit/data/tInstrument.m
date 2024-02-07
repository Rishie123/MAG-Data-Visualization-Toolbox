classdef tInstrument < matlab.mock.TestCase
% TINSTRUMENT Unit tests for "mag.Instrument" class.

    properties (TestParameter)
        HasProperty = {"HasData", "HasMetaData", "HasScience", "HasHK"}
    end

    methods (Test)

        % Test that "Has*" properties return "false" when object has no
        % data.
        function hasProperties_noData(testCase, HasProperty)

            % Set up.
            instrument = mag.Instrument();

            % Exercise and verify.
            testCase.verifyFalse(instrument.(HasProperty), """" + HasProperty + """ should return ""false"" when object has no data.");
        end

        % Test that "TimeRange" is missing when object has no data.
        function timeRange_noData(testCase)

            % Set up.
            instrument = mag.Instrument();

            % Exercise and verify.
            testCase.verifyTrue(all(ismissing(instrument.TimeRange)), """TimeRange"" should return ""missing"" when object has no data.");
        end

        % Test that "TimeRange" is based on both primary and secondary
        % data.
        function timeRange_withData(testCase)

            % % Set up.
            % [instrument, primaryBehavior, secondaryBehavior] = testCase.createTestData();
            % 
            % minTime = datetime("yesterday");
            % maxTime = datetime("tomorrow");
            % 
            % testCase.assignOutputsWhen(get(primaryBehavior.Time), [minTime; datetime("today")]);
            % testCase.assignOutputsWhen(get(secondaryBehavior.Time), [datetime("today"); maxTime]);
            % 
            % expectedTimeRange = [minTime, maxTime];
            % 
            % % Exercise and verify.
            % testCase.verifyEqual(instrument.TimeRange, expectedTimeRange, """TimeRange"" should return minimum and maximum time based on both sensors.");
        end

        % Test that primary sensor name is returned correctly.
        function getSensor_primary(testCase)

            % Set up.
            instrument = mag.Instrument(MetaData = mag.meta.Instrument());
            instrument.MetaData.Primary = "FIB";

            % Exercise and verify.
            testCase.verifyEqual(instrument.getSensor(), mag.meta.Sensor.FIB, "Primary sensor should be returned by default.");
            testCase.verifyEqual(instrument.getSensor("Primary"), mag.meta.Sensor.FIB, "Primary sensor should be returned when asked.");
        end

        % Test that secondary sensor name is returned correctly.
        function getSensor_secondary(testCase)

            % Set up.
            instrument = mag.Instrument(MetaData = mag.meta.Instrument());
            instrument.MetaData.Primary = "FIB";

            % Exercise and verify.
            testCase.verifyEqual(instrument.getSensor("Secondary"), mag.meta.Sensor.FOB, "Secondary sensor should be returned when asked.");
        end

        % Test that "cropScience" method calls method of underlying science
        % data.
        function fillWarmUpMethod(testCase)

            % Set up.
            [instrument, primaryBehavior, secondaryBehavior] = testCase.createTestData();

            timePeriod = minutes(1);
            filler = 1;

            % Exercise.
            instrument.fillWarmUp(timePeriod, filler);

            % Verify.
            testCase.verifyCalled(primaryBehavior.replace(timePeriod, filler), "Primary data should be cropped with same filter.");
            testCase.verifyCalled(secondaryBehavior.replace(timePeriod, filler), "Secondary data should be cropped with same filter.");
        end

        % Test that "cropScience" method calls method of underlying science
        % data.
        function cropScienceMethod(testCase)

            % Set up.
            [instrument, primaryBehavior, secondaryBehavior] = testCase.createTestData();

            timeFilter = timerange(datetime("-Inf", TimeZone = "UTC"), datetime("Inf", TimeZone = "UTC"));

            % Exercise.
            instrument.cropScience(timeFilter);

            % Verify.
            testCase.verifyCalled(primaryBehavior.crop(timeFilter), "Primary data should be cropped with same filter.");
            testCase.verifyCalled(secondaryBehavior.crop(timeFilter), "Secondary data should be cropped with same filter.");
        end

        % Test that "crop" method calls method of underlying science data.
        function cropMethod(testCase)

            % Set up.
            [instrument, primaryBehavior, secondaryBehavior, iALiRTBehavior] = testCase.createTestData();

            timeFilter = timerange(datetime("-Inf", TimeZone = "UTC"), datetime("Inf", TimeZone = "UTC"));
            expectedTimeFilter = timerange(instrument.TimeRange(1), instrument.TimeRange(end), "closed");

            % Exercise.
            instrument.crop(timeFilter);

            % Verify.
            testCase.verifyCalled(primaryBehavior.crop(timeFilter), "Primary data should be cropped with same filter.");
            testCase.verifyCalled(secondaryBehavior.crop(timeFilter), "Secondary data should be cropped with same filter.");
            testCase.verifyCalled(iALiRTBehavior.crop(expectedTimeFilter), "I-ALiRT data should be cropped with same filter.");

            testCase.verifyTrue(all(isbetween(instrument.HK.Time, instrument.TimeRange(1), instrument.TimeRange(end), "closed")), "HK data should be cropped with same filter.");
        end

        % Test that "resample" method calls method of underlying science
        % data.
        function resampleMethod(testCase)

            % Set up.
            [instrument, primaryBehavior, secondaryBehavior] = testCase.createTestData();

            % Exercise.
            instrument.resample(2);

            % Verify.
            testCase.verifyCalled(primaryBehavior.resample(2), "Primary data should be resampled with same frequency.");
            testCase.verifyCalled(secondaryBehavior.resample(2), "Secondary data should be resampled with same frequency.");
        end

        % Test that "downsample" method calls method of underlying science
        % data.
        function downsampleMethod(testCase)

            % Set up.
            [instrument, primaryBehavior, secondaryBehavior] = testCase.createTestData();

            tf = 1 / (60 * 2);

            % Exercise.
            instrument.downsample(tf);

            % Verify.
            testCase.verifyCalled(primaryBehavior.downsample(tf), "Primary data should be downsampled with same frequency.");
            testCase.verifyCalled(secondaryBehavior.downsample(tf), "Secondary data should be downsampled with same frequency.");
        end

        % Test that "copy" method performs a deep copy of all data.
        function copyMethod(testCase)

            % Set up.
            instrument = testCase.createTestData();

            % Exercise.
            copiedInstrument = instrument.copy();

            % Verify.
            testCase.verifyNotSameHandle(instrument, copiedInstrument, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(instrument.MetaData, copiedInstrument.MetaData, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(instrument.Primary, copiedInstrument.Primary, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(instrument.Secondary, copiedInstrument.Secondary, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(instrument.HK, copiedInstrument.HK, "Copied data should be different instance.");
        end

        % Test that displaying a single object displays the correct
        % information.
        function customDisplay_singleObject(testCase)

            % Set up.
            instrument = testCase.createTestData();

            instrument.Primary.MetaData.Mode = "Burst";
            instrument.Primary.MetaData.DataFrequency = 64;
            instrument.Secondary.MetaData.DataFrequency = 8;

            % Exercise.
            output = evalc("display(instrument)");

            % Verify.
            testCase.verifySubstring(eraseTags(output), "in Burst (64, 8)", "Science meta data should be included in display.");
        end

        % Test that displaying heterogeneous arrays does not error.
        function customDisplay_heterogeneous(testCase)

            % Set up.
            instrument = testCase.createTestData();
            instrument = [instrument, instrument]; %#ok<NASGU>

            % Exercise and verify.
            evalc("display(instrument)");
        end
    end

    methods (Access = private)

        function [instrument, primaryBehavior, secondaryBehavior, iALiRTBehavior, hkBehavior] = createTestData(testCase)

            scienceTT = timetable(datetime("now", TimeZone = "UTC") + minutes(1:10)', (1:10)', (11:20)', (21:30)', 3 * ones(10, 1), (1:10)', VariableNames = ["x", "y", "z", "range", "sequence"]);

            [primary, primaryBehavior] = testCase.createMock(?mag.Science, ConstructorInputs = {scienceTT, mag.meta.Science(Timestamp = datetime("now", TimeZone = "UTC"))}, Strict = true);
            [secondary, secondaryBehavior] = testCase.createMock(?mag.Science, ConstructorInputs = {scienceTT, mag.meta.Science(Timestamp = datetime("now", TimeZone = "UTC"))}, Strict = true);

            iALiRTScience = mag.Science(scienceTT, mag.meta.Science(Timestamp = datetime("now", TimeZone = "UTC")));
            [iALiRT, iALiRTBehavior] = testCase.createMock(?mag.IALiRT, ConstructorInputs = {iALiRTScience, iALiRTScience}, Strict = true);

            [hk, hkBehavior] = testCase.createMock(?mag.HK, ConstructorInputs = {scienceTT, mag.meta.HK(Timestamp = datetime("now", TimeZone = "UTC"))}, Strict = true);

            instrument = mag.Instrument(MetaData = mag.meta.Instrument(), ...
                Primary = primary, ...
                Secondary = secondary, ...
                IALiRT = iALiRT, ...
                HK = hk);
        end
    end
end
