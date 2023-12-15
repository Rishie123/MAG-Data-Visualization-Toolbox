classdef tPlot < MAGVisualizationTestCase
% TPLOT Unit tests for "mag.graphics.chart.Plot" class.

    properties (Constant)
        ClassName = "mag.graphics.chart.Plot"
        GraphClassName = "matlab.graphics.chart.primitive.Line"
    end

    properties (TestParameter)
        Properties = {struct(Name = "LineStyle", Value = '-', VerifiableName = "LineStyle"), ...
            struct(Name = "LineStyle", Value = '--', VerifiableName = "LineStyle")}
    end
end
