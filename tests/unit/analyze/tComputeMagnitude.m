classdef tComputeMagnitude < MAGAnalysisTestCase
% TCOMPUTEMAGNITUDE Unit tests for "computeMagnitude" function.

    properties (TestParameter)
        Vector = {[0, 0, 0], [-1, -2, 3], [1, 2, 3; 4, 5, -6]}
        Magnitude = {0, sqrt(1 + 4 + 9), [sqrt(1 + 4 + 9); sqrt(16 + 25 + 36)]}
    end

    methods (Test, ParameterCombination = "sequential")

        function computeMagnitude(testCase, Vector, Magnitude)

            % Set up.
            magnitudeStep = mag.process.Magnitude();

            % Exercise.
            absoluteValue = magnitudeStep.computeMagnitude(Vector);

            % Verify.
            testCase.verifyEqual(absoluteValue, Magnitude, "Magnitude of vector should match expectation.");
        end
    end
end
