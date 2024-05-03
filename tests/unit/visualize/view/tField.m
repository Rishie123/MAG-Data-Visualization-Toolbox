classdef tField < MAGViewTestCase
% TFIELD Unit tests for "mag.graphics.view.Field" class.

    methods (TestClassSetup)

        % Disable visibility for figures while testing.
        function disableFigureVisibility(testCase)

            currentValue = get(groot(), "DefaultFigureVisible");
            testCase.addTeardown(@() set(groot(), DefaultFigureVisible = currentValue));

            set(groot(), DefaultFigureVisible = "off");
        end

        % Close all figures opened by test.
        function closeTestFigures(testCase)
            testCase.applyFixture(mag.test.fixture.CleanupFigures());
        end
    end

    methods (Test)

        % Test that science view is generated correctly.
        function scienceView(testCase)

            % Set up.
            instrument = testCase.createTestInstrument();
            expectedInputs = testCase.generateExpectedInputs(instrument);

            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.graphics.view.Field(instrument, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end

        % Test that custom names are used when provided.
        function customNameTitle(testCase)

            % Set up.
            instrument = testCase.createTestInstrument();

            name = "This is the name";
            title = "This is the title";

            expectedNameValues = {"Name", name, "Title", title};
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyNameValuesAndAssignOutput(expectedOutput, expectedNameValues, varargin)));

            % Exercise.
            view = mag.graphics.view.Field(instrument, Name = name, Title = title, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end
    end

    methods (Static, Access = private)

        function expectedInputs = generateExpectedInputs(instrument, options)

            arguments
                instrument (1, 1) mag.Instrument
                options.PrimaryTitle (1, 1) string = "FIB (FEE4 - LM2 - Some)"
                options.SecondaryTitle (1, 1) string = "FOB (FEE2 - EM4 - None)"
                options.Title (1, 1) string = "Burst (64, 8)"
                options.Name (1, 1) string = "Burst (64, 8) Time Series (NaT)"
            end

            expectedInputs{1} = instrument.Science(2);
            expectedInputs{2} = mag.graphics.style.Stackedplot(Title = options.PrimaryTitle, YLabels =  ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Layout = [3, 1], ...
                Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = instrument.Science(2).Quality.isPlottable()));

            expectedInputs{3} = instrument.Science(1);
            expectedInputs{4} = mag.graphics.style.Stackedplot(Title = options.SecondaryTitle, YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], YAxisLocation = "right", Layout = [3, 1], ...
                Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = instrument.Science(1).Quality.isPlottable()));

            expectedInputs = [expectedInputs, { ...
                "Title", options.Title, ...
                "Name", options.Name, ...
                "Arrangement", [3, 2], ...
                "LinkXAxes", true, ...
                "WindowState", "maximized"}];
        end
    end
end
