classdef tIMAPAnalysis < matlab.unittest.TestCase
% TIMAPANALYSIS Unit tests for "mag.IMAPAnalysis" class.

    properties (TestParameter)
        AliasName = {"mag.IMAPTestingAnalysis", "mag.AutomatedAnalysis"}
    end

    methods (Test)

        % Test that aliases are defined.
        function alias(testCase, AliasName)
            testCase.verifyClass(feval(AliasName), "mag.IMAPAnalysis", sprintf("Alias ""%s"" should exist.", AliasName));
        end
    end
end
