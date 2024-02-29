classdef (Abstract) MAGStyleTestCase < matlab.unittest.TestCase
% MAGSTYLETESTCASE Base class for all axes styles that support extra
% properties.

    properties (Abstract, Constant)
        % CLASSNAME Fully qualified name of class under test.
        ClassName
    end

    methods (Access = protected)

        function args = getExtraArguments(~)
        % GETEXTRAARGUMENTS Retrieve extra arguments needed to construct a
        % chart. Can be overridden by subclasses for customization.

            args = {};
        end
    end
end
