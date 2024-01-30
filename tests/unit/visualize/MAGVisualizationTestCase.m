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
end
