classdef tStackedplot < MarkerSupportTestCase
% TSTACKEDPLOT Unit tests for "mag.graphics.chart.Stackedplot" class.

    properties (Constant)
        ClassName = "mag.graphics.chart.Stackedplot"
        GraphClassName = "matlab.graphics.chart.primitive.Line"
    end

    methods (Test)

        % Test that instantaneous events are correctly displayed on the
        % stackedplot.
        function instantaneousEvents(testCase)

            % Set up.
            data = testCase.createTestDataWithEvents(SetDuration = false, SetEndTime = false);

            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            % Exercise.
            chart = mag.graphics.chart.Stackedplot(YVariables = ["A", "B", "C"], EventsVisible = true);
            assembledGraph = chart.plot(data, ax, tl);

            % Verify.
            % The chart should only return the main objects, but the figure
            % should also show two vertical lines per plot.
            testCase.verifyClass(assembledGraph, "matlab.graphics.chart.primitive.Line", "Graph type should match expectation.");
            testCase.verifyNumElements(assembledGraph, 3, "Number of graphs should match expectation.");

            axes = unique([ax; mag.test.getAllAxes(tl)]);
            graph = [axes.Children];

            testCase.assertSize(graph, [3, 3], "Number of graphs should match expectation.");

            testCase.verifyClass(graph(1:2, :), "matlab.graphics.chart.decoration.ConstantLine", "Event lines should be shown.");
            testCase.verifyEqual({graph(1:2, :).InterceptAxis}, repmat({'x'}, [1, 6]), "Event lines should be vertical.");
            testCase.verifyEqual({graph(1, :).Label}, repmat({'Event 2'}, [1, 3]), "Event name should be shown.");
            testCase.verifyEqual({graph(2, :).Label}, repmat({'Event 1'}, [1, 3]), "Event name should be shown.");

            testCase.verifyClass(graph(3, :), "matlab.graphics.chart.primitive.Line", "Data lines should be shown.");
        end

        % Test that events with durations are correctly displayed on the
        % stackedplot.
        function nonInstantaneousEvents_duration(testCase)

            % Set up.
            data = testCase.createTestDataWithEvents(SetDuration = true, SetEndTime = false);

            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            % Exercise.
            chart = mag.graphics.chart.Stackedplot(YVariables = ["A", "B", "C"], EventsVisible = true);
            assembledGraph = chart.plot(data, ax, tl);

            % Verify.
            % The chart should only return the main objects, but the figure
            % should also show two vertical lines per plot.
            testCase.verifyClass(assembledGraph, "matlab.graphics.chart.primitive.Line", "Graph type should match expectation.");
            testCase.verifyNumElements(assembledGraph, 3, "Number of graphs should match expectation.");

            axes = unique([ax; mag.test.getAllAxes(tl)]);
            graph = [axes.Children];

            testCase.assertSize(graph, [5, 3], "Number of graphs should match expectation.");

            testCase.verifyClass(graph(1:2, :), "matlab.graphics.chart.decoration.ConstantLine", "Event lines should be shown.");
            testCase.verifyEqual({graph(1:2, :).InterceptAxis}, repmat({'x'}, [1, 6]), "Event lines should be vertical.");
            testCase.verifyEqual({graph(1, :).Label}, repmat({'Event 2'}, [1, 3]), "Event name should be shown.");
            testCase.verifyEqual({graph(2, :).Label}, repmat({'Event 1'}, [1, 3]), "Event name should be shown.");

            testCase.verifyClass(graph(3:4, :), "matlab.graphics.chart.decoration.ConstantRegion", "Event regions should be shown.");
            testCase.verifyEqual({graph(3:4, :).InterceptAxis}, repmat({'x'}, [1, 6]), "Event lines should be vertical.");

            testCase.verifyClass(graph(5, :), "matlab.graphics.chart.primitive.Line", "Data lines should be shown.");
        end

        % Test that events with end times are correctly displayed on the
        % stackedplot.
        function nonInstantaneousEvents_endTime(testCase)

            % Set up.
            data = testCase.createTestDataWithEvents(SetDuration = false, SetEndTime = true);

            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            % Exercise.
            chart = mag.graphics.chart.Stackedplot(YVariables = ["A", "B", "C"], EventsVisible = true);
            assembledGraph = chart.plot(data, ax, tl);

            % Verify.
            % The chart should only return the main objects, but the figure
            % should also show two vertical lines per plot.
            testCase.verifyClass(assembledGraph, "matlab.graphics.chart.primitive.Line", "Graph type should match expectation.");
            testCase.verifyNumElements(assembledGraph, 3, "Number of graphs should match expectation.");

            axes = unique([ax; mag.test.getAllAxes(tl)]);
            graph = [axes.Children];

            testCase.assertSize(graph, [5, 3], "Number of graphs should match expectation.");

            testCase.verifyClass(graph(1:2, :), "matlab.graphics.chart.decoration.ConstantLine", "Event lines should be shown.");
            testCase.verifyEqual({graph(1:2, :).InterceptAxis}, repmat({'x'}, [1, 6]), "Event lines should be vertical.");
            testCase.verifyEqual({graph(1, :).Label}, repmat({'Event 2'}, [1, 3]), "Event name should be shown.");
            testCase.verifyEqual({graph(2, :).Label}, repmat({'Event 1'}, [1, 3]), "Event name should be shown.");

            testCase.verifyClass(graph(3:4, :), "matlab.graphics.chart.decoration.ConstantRegion", "Event regions should be shown.");
            testCase.verifyEqual({graph(3:4, :).InterceptAxis}, repmat({'x'}, [1, 6]), "Event lines should be vertical.");

            testCase.verifyClass(graph(5, :), "matlab.graphics.chart.primitive.Line", "Data lines should be shown.");
        end

        % Test that "Color" property can be overridden.
        function setColorProperty(testCase)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            % Exercise.
            chart = feval(testCase.ClassName, Color = [1, 0, 1], YVariables = "Number");
            assembledGraph = chart.plot(testCase.Data, ax, tl);

            % Verify.
            graph = mag.test.GraphicsTestUtilities.getChildrenGraph(testCase, tl, ax, testCase.GraphClassName);

            testCase.verifySameHandle(assembledGraph, graph, "Chart should return assembled graph.");
            testCase.verifyEqual(graph.Color, [1, 0, 1], """Color"" property value should match.");
        end

        % Test that setting "Color" property to empty errors.
        function setColorProperty_error(testCase)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            % Exercise and verify.
            chart = feval(testCase.ClassName, Color = double.empty(), YVariables = "Number");
            testCase.verifyError(@() chart.plot(testCase.Data, ax, tl), ?MException, "Error should be thrown when number of colors does not match number of graphs.");
        end
    end

    methods (Static, Access = private)

        function data = createTestData()
            data = timetable(datetime("now") + seconds(1:10)', (1:10)', (11:20)', (21:30)', VariableNames = ["A", "B", "C"]);
        end

        function data = createTestDataWithEvents(options)

            arguments
                options.SetDuration (1, 1) logical = false
                options.SetEndTime (1, 1) logical = false
            end

            data = tStackedplot.createTestData();

            events = timetable(data.Time([3, 7]), ["Event 1", "Event 2"]', seconds([0, 3])', data.Time([4, 10]), VariableNames = ["Label", "Duration", "End"]);
            events = eventtable(events, EventLabelsVariable = "Label");

            if options.SetDuration
                events.Properties.EventLengthsVariable = "Duration";
            elseif options.SetEndTime
                events.Properties.EventEndsVariable = "End";
            end

            data.Properties.Events = events;
        end
    end
end
