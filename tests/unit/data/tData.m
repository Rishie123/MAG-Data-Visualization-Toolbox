classdef tData < matlab.unittest.TestCase
% TDATA Unit tests for "mag.Data" class.

    methods (Test)

        % Test that meta data "sort" method returns the meta data in the
        % expected order.
        function metadata_sort(testCase)

            % Set up.
            metaData(1) = mag.meta.Science(Timestamp = datetime("today"));
            metaData(2) = mag.meta.Science(Timestamp = datetime("tomorrow"));
            metaData(3) = mag.meta.Science(Timestamp = datetime("yesterday"));

            expectedMetaData = metaData([2, 1, 3]);

            % Exercise.
            sortedMetaData = sort(metaData, "descend");

            % Verify.
            testCase.verifyEqual(sortedMetaData, expectedMetaData, "Sorting should return the expected order.");
        end

        % Test that meta data "struct" method converts to struct.
        function metadata_struct(testCase)

            % Set up.
            metaData = mag.meta.Science(Can = "Can 1", FEE = "FEE3", Model = "EM2", Sensor = "FOB", ...
                Mode = "Burst", DataFrequency = 4, PacketFrequency = 8);

            expectedStruct = struct(Model = "EM2", ...
                FEE = "FEE3", ...
                Can = "Can 1", ...
                Sensor = mag.meta.Sensor.FOB, ...
                Mode = mag.meta.Mode.Burst, ...
                DataFrequency = 4, ...
                PacketFrequency = 8, ...
                ReferenceFrame = string.empty(), ...
                Description = string.empty(), ...
                Timestamp = NaT(TimeZone = "UTC"));

            % Exercise.
            structMetaData = struct(metaData);

            % Verify.
            testCase.verifyEqual(structMetaData, expectedStruct, "Converted struct should have the expected values.");
        end

        % Test that meta data "getDisplay" method returns the correct
        % property value for scalar objects.
        function metadata_getDisplay_empty(testCase)

            % Set up.
            metaData = mag.meta.Science();
            metaData.Model = string.empty();

            % Exercise.
            value = metaData.getDisplay("Model");

            % Verify.
            testCase.verifyEmpty(value, "Display value should be equal to expected value.");
        end

        % Test that meta data "getDisplay" method returns the correct
        % property value for scalar objects.
        function metadata_getDisplay_scalar(testCase)

            % Set up.
            metaData = mag.meta.Science();
            metaData.Model = "FM5";

            expectedValue = "FM5";

            % Exercise.
            value = metaData.getDisplay("Model");

            % Verify.
            testCase.verifyEqual(value, expectedValue, "Display value should be equal to expected value.");
        end

        % Test that meta data "getDisplay" method returns the correct
        % property value for vector objects with the same value.
        function metadata_getDisplay_vectorSameValue(testCase)

            % Set up.
            metaData(1) = mag.meta.Science();
            metaData(2) = mag.meta.Science();
            [metaData.Model] = deal("FM4");

            expectedValue = "FM4";

            % Exercise.
            value = metaData.getDisplay("Model");

            % Verify.
            testCase.verifyEqual(value, expectedValue, "Display value should be equal to expected value.");
        end

        % Test that meta data "getDisplay" method returns missing value for
        % vector objects with different values.
        function metadata_getDisplay_vectorDifferentValues(testCase)

            % Set up.
            metaData(1) = mag.meta.Science();
            metaData(2) = mag.meta.Science();
            [metaData.Model] = deal("FM4", "FM5");

            % Exercise.
            value = metaData.getDisplay("Model");

            % Verify.
            testCase.verifyTrue(ismissing(value), "Display value should be equal to expected value.");
        end

        % Test that meta data "getDisplay" method returns the specified
        % alternative value for vector objects with different values.
        function metadata_getDisplay_vectorCustomAlternative(testCase)

            % Set up.
            metaData(1) = mag.meta.Science();
            metaData(2) = mag.meta.Science();
            [metaData.Model] = deal("FM4", "FM5");

            expectedValue = "Ciao";

            % Exercise.
            value = metaData.getDisplay("Model", expectedValue);

            % Verify.
            testCase.verifyEqual(value, expectedValue, "Display value should be equal to expected value.");
        end

        % Test that "get" method with a single property name returns the
        % selected property.
        function getMethod_singleProperty(testCase)

            % Set up.
            [data, rawData] = testCase.createTestData();

            % Exercise.
            actualData = data.get("Y");

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, "y"}, "Retireved property value should be as expected.");
        end

        % Test that "get" method with multiple scalar property names
        % returns the selected properties.
        function getMethod_multipleProperties_manyScalars(testCase)

            % Set up.
            [data, rawData] = testCase.createTestData();

            % Exercise.
            actualData = data.get("Z", "X");

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, ["z", "x"]}, "Retireved property values should be as expected.");
        end

        % Test that "get" method with a single vector of property names
        % returns the selected properties.
        function getMethod_multipleProperties_singleVector(testCase)

            % Set up.
            [data, rawData] = testCase.createTestData();

            % Exercise.
            actualData = data.get(["Z", "X", "Y"]);

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, ["z", "x", "y"]}, "Retireved property values should be as expected.");
        end

        % Test that "get" method with any other signature calls the
        % built-in method.
        function getMethod_other(testCase)

            % Set up.
            [data, rawData] = testCase.createTestData();

            % Exercise.
            actualData = data.get('Y');

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, "y"}, "Retireved property values should be as expected.");
        end

        % Test that "get" method with an invalid property name throws.
        function getMethod_invalidProperty(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise and verify.
            testCase.verifyError(@() data.get("A"), "MATLAB:class:setgetPropertyNotFound", "Error should be thrown for invalid property.");
        end

        % Test that "get" method with invalid signature throws.
        function getMethod_invalidSignature(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise and verify.
            testCase.verifyError(@() data.get(1), "MATLAB:class:InvalidArgument", "Error should be thrown for invalid signature.");
            testCase.verifyError(@() data.get(1, 2, 3), "MATLAB:maxrhs", "Error should be thrown for invalid signature.");
            testCase.verifyError(@() data.get("A", 2, "C"), "MATLAB:maxrhs", "Error should be thrown for invalid signature.");
            testCase.verifyError(@() data.get('A', 2), "MATLAB:maxrhs", "Error should be thrown for invalid signature.");
        end

        % Test that "copy" method performs a deep copy of meta data.
        function copyMethod(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise.
            copiedData = data.copy();

            % Verify.
            testCase.verifyNotSameHandle(data, copiedData, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(data.MetaData, copiedData.MetaData, "Copied data should be different instance.");
        end
    end

    methods (Static, Access = private)

        function [data, rawData] = createTestData()

            rawData = timetable(datetime("now") + (1:10)', (1:10)', (11:20)', (21:30)', VariableNames = ["x", "y", "z"]);
            data = mag.Science(rawData, mag.meta.Science());
        end
    end
end
