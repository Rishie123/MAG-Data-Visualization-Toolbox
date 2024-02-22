classdef tStep < MAGAnalysisTestCase
% TSTEP Unit tests for "mag.process.Step" classes.

    properties (TestParameter)
        StepClass = tStep.retrieveProcessingSteps()
        PropertyName = {"Name", "Description", "DetailedDescription"}
    end

    methods (Test)

        % Test that calling documentation properties on processing steps
        % does not throw.
        function documentationProperty(testCase, StepClass, PropertyName)

            % Set up.
            stepClass = feval(StepClass);

            % Exercise.
            documentation = stepClass.(PropertyName);

            % Verify.
            testCase.assertClass(documentation, "string", "Documentation property type should be ""string"".");
            testCase.verifyNotEmpty(documentation, "Documentation property value should not be empty.");
        end
    end

    methods (Static, Access = private)

        function classNames = retrieveProcessingSteps()

            metaPackage = meta.package.fromName("mag.process");

            metaClass = metaPackage.ClassList;
            metaClass = metaClass(metaClass < ?mag.process.Step);
            metaClass([metaClass.Abstract]) = [];

            classNames = {metaClass.Name};
        end
    end
end
