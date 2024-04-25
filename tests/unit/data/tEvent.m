classdef tEvent < matlab.unittest.TestCase
% TEVENT Unit tests for "mag.event.Event" classes.

    properties (TestParameter)
        ModeChangeEventData
    end

    methods (Static, TestParameterDefinition)

        function ModeChangeEventData = initializeModeChangeEventData()

            events(1) = mag.event.ModeChange(Mode = "Normal", ...
                PrimaryNormalRate = 4, ...
                SecondaryNormalRate = 1, ...
                PrimaryBurstRate = 128, ...
                SecondaryBurstRate = 64, ...
                PacketNormalFrequency = 8, ...
                PacketBurstFrequency = 2);
            events(2) = mag.event.ModeChange(Mode = "Burst", ...
                PrimaryNormalRate = 2, ...
                SecondaryNormalRate = 2, ...
                PrimaryBurstRate = 64, ...
                SecondaryBurstRate = 64, ...
                PacketNormalFrequency = 8, ...
                PacketBurstFrequency = 4);
            events(3) = mag.event.ModeChange(Mode = "Config");

            ModeChangeEventData{1} = struct(Event = events(1), ...
                ActivePrimaryRate = 4, ...
                ActiveSecondaryRate = 1, ...
                ActivePacketFrequency = 8);
            ModeChangeEventData{2} = struct(Event = events(2), ...
                ActivePrimaryRate = 64, ...
                ActiveSecondaryRate = 64, ...
                ActivePacketFrequency = 4);
            ModeChangeEventData{3} = struct(Event = events(3), ...
                ActivePrimaryRate = NaN, ...
                ActiveSecondaryRate = NaN, ...
                ActivePacketFrequency = NaN);
        end
    end

    methods (Test)

        % Test that events are sorted based on completion time.
        function sort(testCase)

            % Set up.
            events = [mag.event.ModeChange(CompleteTimestamp = datetime("today", TimeZone = "UTC")), ...
                mag.event.RampMode(CompleteTimestamp = datetime("tomorrow", TimeZone = "UTC")), ...
                mag.event.RangeChange(CompleteTimestamp = datetime("yesterday", TimeZone = "UTC"))];

            expectedEvents = events([3, 1, 2]);

            % Exercise.
            sortedEvents = sort(events);

            % Verify.
            testCase.verifyEqual(sortedEvents, expectedEvents, "Sorting should return the expected order.");
        end

        % Test that "ModeChange" events are converted to "timetable"
        % correctly.
        function timetable_modeChange(testCase)

            % Set up.
            events = testCase.createModeChangeEvents();

            % Exercise.
            tt = events.timetable();

            % Verify.
            testCase.assertClass(tt, "timetable", "Timetable should be of correct class.");
            testCase.assertSize(tt, [3, 12], "Timetable should be of correct size.");

            for v = ["Mode", "PrimaryNormalRate", "SecondaryNormalRate", "PacketNormalFrequency", "PrimaryBurstRate", "SecondaryBurstRate", "PacketBurstFrequency", "Duration"]
                testCase.verifyEqual(tt.(v)', [events.(v)], compose("Timetable property ""%s"" should match event.", v));
            end

            for v = ["Range", "Sensor"]
                testCase.verifyTrue(all(ismissing(tt.(v))), compose("Timetable property ""%s"" should be missing.", v));
            end

            testCase.verifyEqual(tt.Label(1), "Normal (4, 1)", "Label of first event should match expectation.");
            testCase.verifyEqual(tt.Label(2), "Burst (128, 128)", "Label of second event should match expectation.");
            testCase.verifyEqual(tt.Label(3), "Normal (4, 4)", "Label of third event should match expectation.");

            testCase.verifyEqual(tt.Time', [events(1).CompleteTimestamp, events(2).AcknowledgeTimestamp, events(3).CommandTimestamp], ...
                "Event timestamps should match expected ones.");

            testCase.verifyEqual(tt.Reason, repmat("Command", 3, 1), "Reason of all events should be ""Command"".");
        end

        % Test that "RangeChange" events are converted to "timetable"
        % correctly.
        function timetable_rangeChange(testCase)

            % Set up.
            events = testCase.createRangeChangeEvents();

            % Exercise.
            tt = events.timetable();

            % Verify.
            testCase.assertClass(tt, "timetable", "Timetable should be of correct class.");
            testCase.assertSize(tt, [3, 12], "Timetable should be of correct size.");

            for v = ["Range", "Sensor"]
                testCase.verifyEqual(tt.(v)', [events.(v)], compose("Timetable property ""%s"" should match event.", v));
            end

            for v = ["Mode", "PrimaryNormalRate", "SecondaryNormalRate", "PacketNormalFrequency", "PrimaryBurstRate", "SecondaryBurstRate", "PacketBurstFrequency", "Duration"]
                testCase.verifyTrue(all(ismissing(tt.(v))), compose("Timetable property ""%s"" should be missing.", v));
            end

            testCase.verifyEqual(tt.Label(1), "FOB Range 2", "Label of first event should match expectation.");
            testCase.verifyEqual(tt.Label(2), "FIB Range 1", "Label of second event should match expectation.");
            testCase.verifyEqual(tt.Label(3), "FOB Range 3", "Label of third event should match expectation.");

            testCase.verifyEqual(tt.Time', [events(1).CompleteTimestamp, events(2).AcknowledgeTimestamp, events(3).CommandTimestamp], ...
                "Event timestamps should match expected ones.");

            testCase.verifyEqual(tt.Reason, repmat("Command", 3, 1), "Reason of all events should be ""Command"".");
        end

        % Test that "RampMode" events are converted to "timetable"
        % correctly.
        function timetable_rampMode(testCase)

            % Set up.
            events = testCase.createRampModeEvents();

            % Exercise.
            tt = events.timetable();

            % Verify.
            testCase.assertClass(tt, "timetable", "Timetable should be of correct class.");
            testCase.assertSize(tt, [3, 12], "Timetable should be of correct size.");

            for v = "Sensor"
                testCase.verifyEqual(tt.(v)', [events.(v)], compose("Timetable property ""%s"" should match event.", v));
            end

            for v = ["Mode", "PrimaryNormalRate", "SecondaryNormalRate", "PacketNormalFrequency", "PrimaryBurstRate", "SecondaryBurstRate", "PacketBurstFrequency", "Duration", "Range"]
                testCase.verifyTrue(all(ismissing(tt.(v))), compose("Timetable property ""%s"" should be missing.", v));
            end

            testCase.verifyEqual(tt.Label(1), "FOB Ramp", "Label of first event should match expectation.");
            testCase.verifyEqual(tt.Label(2), "FIB Ramp", "Label of second event should match expectation.");
            testCase.verifyEqual(tt.Label(3), "FOB Ramp", "Label of third event should match expectation.");

            testCase.verifyEqual(tt.Time', [events(1).CompleteTimestamp, events(2).AcknowledgeTimestamp, events(3).CommandTimestamp], ...
                "Event timestamps should match expected ones.");

            testCase.verifyEqual(tt.Reason, repmat("Command", 3, 1), "Reason of all events should be ""Command"".");
        end

        % Test that "ModeChange" events are converted to "eventtable"
        % correctly.
        function eventtable_modeChange(testCase)

            % Set up.
            events = testCase.createModeChangeEvents();

            % Exercise.
            et = events.eventtable();

            % Verify.
            testCase.assertClass(et, "eventtable", "Event table should be of correct class.");
            testCase.assertSize(et, [4, 12], "Eventtable should be of correct size.");

            for v = ["PrimaryNormalRate", "SecondaryNormalRate", "PacketNormalFrequency", "PrimaryBurstRate", "SecondaryBurstRate", "PacketBurstFrequency"]
                testCase.verifyEqual(et{3, v}, events(2).(v), compose("Timetable property ""%s"" should match event.", v));
            end

            for v = ["Range", "Sensor"]
                testCase.verifyTrue(ismissing(et{3, v}), compose("Timetable property ""%s"" should be missing.", v));
            end

            testCase.verifyEqual(et.Mode(3), "Normal", "Mode of auto event should match expectation.");
            testCase.verifyEqual(et.Duration(3), 0, "Duration of auto event should match expectation.");
            testCase.verifyEqual(et.Label(3), "Normal (2, 2)", "Label of auto event should match expectation.");
            testCase.verifyEqual(et.Time(3), events(2).AcknowledgeTimestamp + seconds(events(2).Duration), "Auto event timestamps should match expectation.");
        end

        % Test that dependent "active" properties of "ModeChange" select
        % correct active value.
        function modeChange_dependentProperties(testCase, ModeChangeEventData)

            % Exercise and verify.
            for v = ["ActivePrimaryRate", "ActiveSecondaryRate", "ActivePacketFrequency"]
                testCase.verifyEqual(ModeChangeEventData.Event.(v), ModeChangeEventData.(v), "Event active property ""%s"" should match expectation.");
            end
        end
    end

    methods (Static, Access = private)

        function events = createModeChangeEvents()

            events(1) = mag.event.ModeChange(CompleteTimestamp = datetime("yesterday", TimeZone = "UTC"), ...
                Type = 1, SubType = 2, ...
                Mode = "Normal", ...
                PrimaryNormalRate = 4, ...
                SecondaryNormalRate = 1, ...
                PrimaryBurstRate = 128, ...
                SecondaryBurstRate = 64, ...
                PacketNormalFrequency = 8, ...
                PacketBurstFrequency = 2);

            events(2) = mag.event.ModeChange(AcknowledgeTimestamp = datetime("today", TimeZone = "UTC"), ...
                Type = 3, SubType = 4, ...
                Mode = "Burst", ...
                PrimaryNormalRate = 2, ...
                SecondaryNormalRate = 2, ...
                PrimaryBurstRate = 128, ...
                SecondaryBurstRate = 128, ...
                PacketNormalFrequency = 8, ...
                PacketBurstFrequency = 2, ...
                Duration = 3600);

            events(3) = mag.event.ModeChange(CommandTimestamp = datetime("tomorrow", TimeZone = "UTC"), ...
                Type = 5, SubType = 6, ...
                Mode = "Normal", ...
                PrimaryNormalRate = 4, ...
                SecondaryNormalRate = 4, ...
                PrimaryBurstRate = 64, ...
                SecondaryBurstRate = 8, ...
                PacketNormalFrequency = 8, ...
                PacketBurstFrequency = 4);
        end

        function events = createRangeChangeEvents()

            events(1) = mag.event.RangeChange(CompleteTimestamp = datetime("yesterday", TimeZone = "UTC"), ...
                Type = 1, SubType = 2, ...
                Range = 2, Sensor = "FOB");

            events(2) = mag.event.RangeChange(AcknowledgeTimestamp = datetime("today", TimeZone = "UTC"), ...
                Type = 3, SubType = 4, ...
                Range = 1, Sensor = "FIB");

            events(3) = mag.event.RangeChange(CommandTimestamp = datetime("tomorrow", TimeZone = "UTC"), ...
                Type = 5, SubType = 6, ...
                Range = 3, Sensor = "FOB");
        end

        function events = createRampModeEvents()

            events(1) = mag.event.RampMode(CompleteTimestamp = datetime("yesterday", TimeZone = "UTC"), ...
                Type = 1, SubType = 2, ...
                Sensor = "FOB");

            events(2) = mag.event.RampMode(AcknowledgeTimestamp = datetime("today", TimeZone = "UTC"), ...
                Type = 3, SubType = 4, ...
                Sensor = "FIB");

            events(3) = mag.event.RampMode(CommandTimestamp = datetime("tomorrow", TimeZone = "UTC"), ...
                Type = 5, SubType = 6, ...
                Sensor = "FOB");
        end
    end
end
