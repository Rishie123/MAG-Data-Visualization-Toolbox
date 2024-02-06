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
    end

    methods (Access = private)

        function [instrument, primaryBehavior, secondaryBehavior, hkBehavior] = createTestData(testCase)

            [primary, primaryBehavior] = testCase.createMock(?mag.Science, ConstructorInputs = {timetable.empty(), mag.meta.Science()}, Strict = true);
            [secondary, secondaryBehavior] = testCase.createMock(?mag.Science, ConstructorInputs = {timetable.empty(), mag.meta.Science()}, Strict = true);

            [hk, hkBehavior] = testCase.createMock(?mag.HK, ConstructorInputs = {timetable.empty(), mag.meta.HK()});

            instrument = mag.Instrument(MetaData = mag.meta.Instrument(), ...
                Primary = primary, ...
                Secondary = secondary, ...
                HK = hk);
        end
    end
end
