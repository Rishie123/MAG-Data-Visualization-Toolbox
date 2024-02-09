classdef tScatterhistogram < MAGVisualizationTestCase
% TSCATTERHISTOGRAM Unit tests for "mag.graphics.chart.Scatterhistogram"
% class.

    properties (Constant)
        ClassName = "mag.graphics.chart.Scatterhistogram"
        GraphClassName = "matlab.graphics.chart.primitive.Scatter"
    end

    methods (Test)

        % Test that the group variable can be set to empty.
        function setGroupVariable_empty(testCase)

            % Set up.
            [tl, ax] = GraphicsTestUtilities.createFigure(testCase);

            % Exercise.
            chart = mag.graphics.chart.Scatterhistogram(XVariable = "Categorical", ...
                YVariables = "Number", ...
                GVariable = string.empty());

            assembledGraph = chart.plot(testCase.Data, ax, tl);

            % Verify.
            axes = unique(mag.graphics.getAllAxes(tl));
            graph = vertcat(axes.Children);

            testCase.assertNumElements(graph, 3, "Scatter-histogram should create 3 objects.");

            testCase.verifySameHandle(assembledGraph, unique([graph.Parent]), "Chart should return assembled graph.");
            testCase.verifyEmpty(assembledGraph.GroupVariable, """GroupVariable"" property value should be empty.");
            testCase.verifyEmpty(assembledGraph.GroupData, """GroupData"" property value should be empty.");
        end

        % Test that the group variable can be set to a table variable.
        function setGroupVariable(testCase)

            % Set up.
            [tl, ax] = GraphicsTestUtilities.createFigure(testCase);

            % Exercise.
            chart = mag.graphics.chart.Scatterhistogram(XVariable = "Categorical", ...
                YVariables = "Number", ...
                GVariable = "Letter");

            assembledGraph = chart.plot(testCase.Data, ax, tl);

            % Verify.
            axes = unique(mag.graphics.getAllAxes(tl));
            graph = vertcat(axes.Children);

            testCase.assertNumElements(graph, 40, "Scatter-histogram should create 21 objects.");

            testCase.verifySameHandle(assembledGraph, unique([graph.Parent]), "Chart should return assembled graph.");
            testCase.verifyEmpty(assembledGraph.GroupVariable, """GroupVariable"" property value should be empty.");
            testCase.verifyEqual(assembledGraph.GroupData, testCase.Data.Letter, """GroupData"" property value should match expectation.");
        end
    end
end
