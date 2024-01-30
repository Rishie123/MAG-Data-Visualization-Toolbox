classdef (Abstract) ColorSupportTestCase < MAGVisualizationTestCase
% COLORSUPPORTTESTCASE Base class for all charts that support colors.

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

            [~, verifiableValue] = GraphicsTestUtilities.getVerifiables(ColorProperties);
            testCase.verifyEqual(graph.(testCase.getColorPropertyName()), verifiableValue, compose("""%s"" property value should match.", ColorProperties.Name));
        end
    end

    methods (Static, Access = protected)

        function name = getColorPropertyName()
        % GETCOLORPROPERTYNAME Retrieve name of property defining color.
        % Can be overridden by subclasses for customization.

            name = "Color";
        end
    end
end
