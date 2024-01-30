classdef (Abstract) MAGVisualizationTestCase < matlab.unittest.TestCase
% MAGVISUALIZATIONTESTCASE Base class for all MAG visualization tests.

    properties (Constant)
        % DATA Test data.
        Data timetable = timetable(datetime("now") + (1:10)', (1:10)', "a" + (1:10)')
    end

    properties (Abstract, Constant)
        % CLASSNAME Fully qualified name of class under test.
        ClassName (1, 1) string
        % GRAPHCLASSNAME Fully qualified name of graph generated.
        GraphClassName (1, 1) string
    end

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
