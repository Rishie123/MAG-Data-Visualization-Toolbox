classdef tDownsample < MAGAnalysisTestCase
% TDOWNSAMPLE Unit tests for "downsample" function.

    methods (TestClassSetup)

        function initializeRandomGeneration(testCase)

            state = rng();
            testCase.addTeardown(@() rng(state));

            rng(0);
        end
    end

    methods (Test)

        function downsample(testCase)

            % Set up.
            t = datetime("now") + seconds(1:0.1:10);
            b = rand(numel(t), 3);

            data = timetable(t', b(:, 1), b(:, 2), b(:, 3), VariableNames = ["x", "y", "z"]);

            downsampleStep = mag.process.Downsample(TargetFrequency = 2);

            % Exercise.
            downsampledData = downsampleStep.downsample(data);

            % Verify.
            testCase.verifyTrue(all(seconds(diff(downsampledData.Time)) == 0.5), "Data frequency should be updated.");
        end
    end
end
