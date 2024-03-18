classdef tSeparate < MAGAnalysisTestCase
% TSEPARATE Unit tests for "mag.process.Separate" classes.

    methods (Test)

        % Test that adding separation row with specific variables only
        % applies to those variables.
        function namedVariables(testCase)

            % Set up.
            data = testCase.createTestData();

            missingVariables = ["Doubles", "Strings"];
            nonMissingVariables = setdiff(data.Properties.VariableNames, missingVariables);

            % Exercise.
            separateStep = mag.process.Separate(DiscriminationVariable = "Discriminator", Variables = missingVariables);
            processedData = separateStep.apply(data);

            % Verify.
            testCase.assertSize(processedData, [height(data) + 1, width(data)], "Separation row should have been added.");

            testCase.verifyTrue(all(ismissing(processedData(end, missingVariables))), "Selected variables should be missing.");
            testCase.verifyFalse(any(ismissing(processedData(end, nonMissingVariables))), "Other variables should not be missing.");

            testCase.verifyGreaterThanOrEqual(data{end, "Discriminator"}, processedData{end, "Discriminator"}, "Discrimination variable should be increased.");
        end

        % Test that adding separation row with all variables only
        % applies to variables that support .
        function allVariables(testCase)

            % Set up.
            data = testCase.createTestData();

            nonMissingVariables = ["Integers", "Logicals", "Discriminator"];
            missingVariables = setdiff(data.Properties.VariableNames, nonMissingVariables);

            % Exercise.
            separateStep = mag.process.Separate(DiscriminationVariable = "Discriminator", Variables = "*");
            processedData = separateStep.apply(data);

            % Verify.
            testCase.assertSize(processedData, [height(data) + 1, width(data)], "Separation row should have been added.");

            testCase.verifyTrue(all(ismissing(processedData(end, missingVariables))), "Selected variables should be missing.");
            testCase.verifyFalse(any(ismissing(processedData(end, nonMissingVariables))), "Other variables should not be missing.");

            testCase.verifyGreaterThanOrEqual(data{end, "Discriminator"}, processedData{end, "Discriminator"}, "Discrimination variable should be increased.");
        end
    end

    methods (Static, Access = protected)

        function data = createTestData()

            data = table(ones(3, 1), ones(3, 1, "uint32"), minutes([3; 2; 1]), true(3, 1), [datetime("yesterday"); datetime("today"); datetime("now")], ["A"; "B"; "C"], [1; 2; 3], ...
                VariableNames = ["Doubles", "Integers", "Durations", "Logicals", "Dates", "Strings", "Discriminator"]);
        end
    end
end
