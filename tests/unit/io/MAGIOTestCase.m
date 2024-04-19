classdef (Abstract) MAGIOTestCase < matlab.unittest.TestCase
% MAGIOTESTCASE Base class for all IO tests.

    properties (Constant, Access = protected)
        TestDataLocation = fullfile(fileparts(mfilename("fullpath")), "data")
    end
end
