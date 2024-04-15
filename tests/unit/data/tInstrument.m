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

            % Set up.
            instrument = testCase.createTestData();

            minTime = datetime("yesterday", TimeZone = "UTC");
            maxTime = datetime("tomorrow", TimeZone = "UTC");

            instrument.Primary.Data.Time(1) = minTime;
            instrument.Secondary.Data.Time(end) = maxTime;

            expectedTimeRange = [minTime, maxTime];

            % Exercise and verify.
            testCase.verifyEqual(instrument.TimeRange, expectedTimeRange, """TimeRange"" should return minimum and maximum time based on both sensors.");
        end

        % Test that "fillWarmUp" method calls method of underlying science
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
            [instrument, primaryBehavior, secondaryBehavior, iALiRTBehavior] = testCase.createTestData();

            timeFilter = timerange(datetime("-Inf", TimeZone = "UTC"), datetime("Inf", TimeZone = "UTC"));

            % Exercise.
            instrument.cropScience(timeFilter);

            % Verify.
            testCase.verifyCalled(primaryBehavior.crop(timeFilter), "Primary data should be cropped with same filter.");
            testCase.verifyCalled(secondaryBehavior.crop(timeFilter), "Secondary data should be cropped with same filter.");
            testCase.verifyCalled(iALiRTBehavior.crop(timeFilter, timeFilter), "I-ALiRT data should be cropped with expected filter.");
        end

        % Test that "crop" method calls method of underlying science data.
        function cropMethod(testCase)

            % Set up.
            [instrument, primaryBehavior, secondaryBehavior, iALiRTBehavior] = testCase.createTestData();

            timeFilter = timerange(datetime("-Inf", TimeZone = "UTC"), datetime("Inf", TimeZone = "UTC"));

            % Exercise.
            instrument.crop(timeFilter);

            % Verify.
            testCase.verifyCalled(primaryBehavior.crop(timeFilter), "Primary data should be cropped with same filter.");
            testCase.verifyCalled(secondaryBehavior.crop(timeFilter), "Secondary data should be cropped with same filter.");
            testCase.verifyCalled(iALiRTBehavior.crop(timeFilter, timeFilter), "I-ALiRT data should be cropped with same filter.");

            testCase.verifyTrue(all(isbetween(instrument.HK.Time, instrument.TimeRange(1), instrument.TimeRange(2), "closed")), "HK data should be cropped with same filter.");
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

            [primary, primaryBehavior] = testCase.createMock(?mag.Science, ConstructorInputs = {scienceTT, mag.meta.Science(Primary = true, Sensor = "FOB", Timestamp = datetime("now", TimeZone = "UTC"))}, Strict = true);
            [secondary, secondaryBehavior] = testCase.createMock(?mag.Science, ConstructorInputs = {scienceTT, mag.meta.Science(Sensor = "FIB", Timestamp = datetime("now", TimeZone = "UTC"))}, Strict = true);

            iALiRTPrimaryScience = mag.Science(scienceTT, mag.meta.Science(Primary = true, Sensor = "FOB", Timestamp = datetime("now", TimeZone = "UTC")));
            iALiRTSecondaryScience = mag.Science(scienceTT, mag.meta.Science(Sensor = "FIB", Timestamp = datetime("now", TimeZone = "UTC")));
            [iALiRT, iALiRTBehavior] = testCase.createMock(?mag.IALiRT, ConstructorInputs = {iALiRTPrimaryScience, iALiRTSecondaryScience}, Strict = true);

            [hk, hkBehavior] = testCase.createMock(?mag.HK, ConstructorInputs = {scienceTT, mag.meta.HK(Timestamp = datetime("now", TimeZone = "UTC"))}, Strict = true);

            instrument = mag.Instrument(MetaData = mag.meta.Instrument(), ...
                Science = [primary, secondary], ...
                IALiRT = iALiRT, ...
                HK = hk);
        end
    end
end
