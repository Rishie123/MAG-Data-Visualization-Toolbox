classdef GraphicsTestUtilities
% GRAPHICSTESTUTILITIES Utilities for graphics tests.

    methods (Static)

        function ax = createAxes(testCase)
        % CREATEAXES Create figure axes for test.

            arguments
                testCase (1, 1) matlab.unittest.TestCase
            end

            f = figure(Visible = "off");
            testCase.addTeardown(@() close(f));

            ax = axes(f);
        end

        function graph = getChildrenGraph(testCase, axes, type)
        % GETCHILDRENGRAPH Get graph from axes and verify its type.

            arguments
                testCase (1, 1) matlab.unittest.TestCase
                axes (1, 1) matlab.graphics.axis.Axes
                type (1, 1) string
            end

            graph = axes.Children;

            testCase.assertNumElements(graph, 1, "One and only one graph should exist.");
            testCase.assertClass(graph, type, "Graph type should match expectation.");
        end

        function [name, value] = getVerifiables(properties)

            arguments
                properties (1, 1) struct
            end

            if isfield(properties, "VerifiableName")
                name = properties.VerifiableName;
            else
                name = properties.Name;
            end

            if isfield(properties, "VerifiableValue")
                value = properties.VerifiableValue;
            else
                value = properties.Value;
            end
        end
    end
end
