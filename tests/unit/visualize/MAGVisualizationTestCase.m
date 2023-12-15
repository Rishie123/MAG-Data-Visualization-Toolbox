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
            ax = testCase.createAxes();

            % Exercise.
            chart = feval(testCase.ClassName, ...
                Properties.Name, Properties.Value, ...
                YVariables = "Var1");

            chart.plot(testCase.Data, ax, []);

            % Verify.
            graph = testCase.getChildrenGraph(ax, testCase.GraphClassName);

            testCase.verifyEqual(graph.(Properties.VerifiableName), Properties.Value, compose("""%s"" property value should match.", Properties.Name));
        end
    end

    methods (Access = protected)

        function ax = createAxes(testCase)
        % CREATEAXES Create figure axes for test.

            f = figure(Visible = "off");
            testCase.addTeardown(@() close(f));

            ax = axes(f);
        end

        function graph = getChildrenGraph(testCase, axes, type)
        % GETCHILDRENGRAPH Get graph from axes and verify its type.

            graph = axes.Children;

            testCase.assertNumElements(graph, 1, "One and only one graph should exist.");
            testCase.assertClass(graph, type, "Graph type should match expectation.");
        end
    end
end
