classdef tIALiRT < matlab.mock.TestCase
% TIALIRT Unit tests for "mag.IALiRT" class.

    methods (Test)

        % Test that "crop" method calls method of underlying science data.
        function cropMethod(testCase)

            % Set up.
            [iALiRT, primaryBehavior, secondaryBehavior] = testCase.createTestData();

            timeFilter = timerange(datetime("-Inf"), datetime("Inf"));

            % Exercise.
            iALiRT.crop(timeFilter);

            % Verify.
            testCase.verifyCalled(primaryBehavior.crop(timeFilter), "Primary data should be cropped with same filter.");
            testCase.verifyCalled(secondaryBehavior.crop(timeFilter), "Secondary data should be cropped with same filter.");
        end

        % Test that "copy" method performs a deep copy of all data.
        function copyMethod(testCase)

            % Set up.
            iALiRT = testCase.createTestData();

            % Exercise.
            copiedIALiRT = iALiRT.copy();

            % Verify.
            testCase.verifyNotSameHandle(iALiRT, copiedIALiRT, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(iALiRT.Primary, copiedIALiRT.Primary, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(iALiRT.Secondary, copiedIALiRT.Secondary, "Copied data should be different instance.");
        end
    end

    methods (Access = private)

        function [iALiRT, primaryBehavior, secondaryBehavior] = createTestData(testCase)

            [primary, primaryBehavior] = testCase.createMock(?mag.Science, ConstructorInputs = {timetable.empty(), mag.meta.Science()}, Strict = true);
            [secondary, secondaryBehavior] = testCase.createMock(?mag.Science, ConstructorInputs = {timetable.empty(), mag.meta.Science()}, Strict = true);

            iALiRT = mag.IALiRT(primary, secondary);
        end
    end
end
