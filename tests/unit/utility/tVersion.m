classdef tVersion < matlab.unittest.TestCase
% TVERSION Unit tests for "mag.version" function.

    methods (Test)

        % Test that "mag.version" returns a version that is Semantic
        % Versioning 2.0.0-compatible.
        function version(testCase)
            testCase.verifyMatches(mag.version(), "\d+\.\d+\.\d+", "MAG Data Visualization version should match Semantic Versioning 2.0.0.");
        end
    end
end
