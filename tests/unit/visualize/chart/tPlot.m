classdef tPlot < PropertiesTestCase & ColorSupportTestCase & MarkerSupportTestCase
% TPLOT Unit tests for "mag.graphics.chart.Plot" class.

    properties (Constant)
        ClassName = "mag.graphics.chart.Plot"
        GraphClassName = "matlab.graphics.chart.primitive.Line"
    end

    properties (TestParameter)
        Properties = {struct(Name = "LineStyle", Value = '-'), ...
            struct(Name = "LineStyle", Value = '--')}
    end
end
