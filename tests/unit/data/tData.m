classdef tData < matlab.unittest.TestCase
% TDATA Unit tests for "mag.Data" class.

    methods (Test)

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
            dataCopy = data.copy();

            % Verify.
            testCase.verifyNotSameHandle(data, dataCopy, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(data.MetaData, dataCopy.MetaData, "Copied data should be different instance.");
        end
    end

    methods (Static, Access = private)

        function [data, rawData] = createTestData()

            rawData = timetable(datetime("now") + (1:10)', (1:10)', (11:20)', (21:30)', VariableNames = ["x", "y", "z"]);
            data = mag.Science(rawData, mag.meta.Science);
        end
    end
end
