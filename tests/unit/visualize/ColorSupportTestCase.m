classdef (Abstract) ColorSupportTestCase < matlab.unittest.TestCase
% COLORSUPPORTTESTCASE Base class for all charts that support markers.

    properties (TestParameter)
        ColorProperties = {struct(Name = "Color", Value = 'g', VerifiableValue = [0, 1, 0]), ...
            struct(Name = "Color", Value = [1, 0, 1], VerifiableValue = [1, 0, 1]), ...
            struct(Name = "Color", Value = "#FFFF00", VerifiableValue = [1, 1, 0])}
    end

    methods (Test)

        function setColorProperty(testCase, ColorProperties)

            % Set up.
            ax = GraphicsTestUtilities.createAxes(testCase);

            % Exercise.
            chart = feval(testCase.ClassName, ...
                ColorProperties.Name, ColorProperties.Value, ...
                YVariables = "Var1");

            chart.plot(testCase.Data, ax, []);

            % Verify.
            graph = GraphicsTestUtilities.getChildrenGraph(testCase, ax, testCase.GraphClassName);

            [verifiableName, verifiableValue] = GraphicsTestUtilities.getVerifiables(ColorProperties);
            testCase.verifyEqual(graph.(verifiableName), verifiableValue, compose("""%s"" property value should match.", ColorProperties.Name));
        end
    end
end
