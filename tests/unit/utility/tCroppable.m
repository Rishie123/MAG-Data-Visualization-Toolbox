classdef tCroppable < matlab.mock.TestCase
% TCROPPABLE Unit tests for "mag.mixin.Croppable" class.

    properties (Constant, Access = private)
        Time (1, :) datetime = datetime(2024, 3, 14, 15, 9, 27, TimeZone = "UTC")  + seconds(1:10)
    end

    properties (TestParameter)
        TimeDetails
        ValidValue = {timerange(), withtol(), hours(3), -days(14), [seconds(15), minutes(9)]}
        InvalidValue = {1, {timerange()}, {withtol(), withtol()}, [hours(3), seconds(14), minutes(15)]}
    end

    methods (Static, TestParameterDefinition)

        function TimeDetails = initializeTimeDetails()

            time = tCroppable.Time;

            TimeDetails = {struct(Filter = timerange(time(2), time(6), "openleft"), Period = timerange(time(2), time(6), "openleft")), ...
                struct(Filter = withtol(time(5), seconds(2)), Period = withtol(time(5), seconds(2))), ...
                struct(Filter = seconds(1), Period = timerange(time(2), time(end), "closed")), ...
                struct(Filter = -seconds(2), Period = timerange(time(1), time(8), "closed")), ...
                struct(Filter = [seconds(3), seconds(8)], Period = timerange(time(4), time(9), "closed"))};
        end
    end

    methods (Test)

        % Test that "mustBeTimeFilter" does not error on valid values.
        function mustBeTimeFilter_valid(testCase, ValidValue)

            % Set up.
            croppable = testCase.createMock(?mag.mixin.Croppable, Strict = true);

            % Exercise and verify.
            croppable.mustBeTimeFilter(ValidValue);
        end

        % Test that "mustBeTimeFilter" errors on invalid values.
        function mustBeTimeFilter_invalid(testCase, InvalidValue)

            % Set up.
            croppable = testCase.createMock(?mag.mixin.Croppable, Strict = true);

            % Exercise and verify.
            testCase.verifyError(@() croppable.mustBeTimeFilter(InvalidValue), ?MException, ...
                "Error should be thrown on invalid value.");
        end

        % Test that "convertToTimeSubscript" method accepts supported
        % types.
        function convertToTimeSubscript(testCase, TimeDetails)

            % Set up.
            croppable = testCase.createMock(?mag.mixin.Croppable, Strict = true);

            % Exercise.
            timePeriod = croppable.convertToTimeSubscript(TimeDetails.Filter, testCase.Time);

            % Verify.
            testCase.verifyEqual(timePeriod, TimeDetails.Period, "Time period should match expectation.");
        end
    end
end
