classdef (Abstract) MAGVisualizationTestCase < matlab.unittest.TestCase
% MAGVISUALIZATIONTESTCASE Base class for all MAG visualization tests.

    properties (Constant)
        % DATA Test data.
        Data timetable = timetable(datetime("now") + (1:10)', (1:10)', "a" + (1:10)', VariableNames = ["Number", "Letter"])
    end

    properties (Abstract, Constant)
        % CLASSNAME Fully qualified name of class under test.
        ClassName
        % GRAPHCLASSNAME Fully qualified name of graph generated.
        GraphClassName
    end
end
