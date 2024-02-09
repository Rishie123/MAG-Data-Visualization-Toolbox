classdef (Abstract) PropertiesTestCase < MAGVisualizationTestCase
% PROPERTIESTESTCASE Base class for all charts that support extra
% properties.

    properties (Abstract, TestParameter)
        Properties (1, :) cell
    end

    methods (Test)

        function setSimpleProperty(testCase, Properties)

            % Set up.
            [tl, ax] = GraphicsTestUtilities.createFigure(testCase);

            % Exercise.
            chart = feval(testCase.ClassName, ...
                Properties.Name, Properties.Value, ...
                YVariables = "Number");

            chart.plot(testCase.Data, ax, tl);

            % Verify.
            graph = GraphicsTestUtilities.getChildrenGraph(testCase, tl, ax, testCase.GraphClassName);

            [verifiableName, verifiableValue] = GraphicsTestUtilities.getVerifiables(Properties);
            testCase.verifyEqual(graph.(verifiableName), verifiableValue, compose("""%s"" property value should match.", Properties.Name));
        end
    end
end
