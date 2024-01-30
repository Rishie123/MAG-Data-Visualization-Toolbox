classdef (Abstract) PropertiesTestCase < MAGVisualizationTestCase
% PROPERTIESTESTCASE Base class for all charts that support extra
% properties.

    properties (Abstract, TestParameter)
        Properties (1, :) cell
    end

    methods (Test)

        function setSimpleProperty(testCase, Properties)

            % Set up.
            ax = GraphicsTestUtilities.createAxes(testCase);

            % Exercise.
            chart = feval(testCase.ClassName, ...
                Properties.Name, Properties.Value, ...
                YVariables = "Var1");

            chart.plot(testCase.Data, ax, []);

            % Verify.
            graph = GraphicsTestUtilities.getChildrenGraph(testCase, ax, testCase.GraphClassName);

            [verifiableName, verifiableValue] = GraphicsTestUtilities.getVerifiables(Properties);
            testCase.verifyEqual(graph.(verifiableName), verifiableValue, compose("""%s"" property value should match.", Properties.Name));
        end
    end
end
