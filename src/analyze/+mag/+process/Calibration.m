classdef Calibration < mag.process.Step
% CALIBRATION Correct data by applying scale factor, misalignment and
% offset.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % CALIBRATIONFILE File containing scale factor, misalignment and
        % offset information.
        CalibrationFile (1, 1) string {mustBeFile} = fullfile(fileparts(mfilename("fullpath")), "../../data/fobCalibration.txt")
    end

    methods

        function this = Calibration(options)

            arguments
                options.?mag.process.Calibration
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Calibration";
        end

        function value = get.Description(~)
            value = "Calibrate science data by applying scale factor, misalignment and offset.";
        end

        function value = get.DetailedDescription(this)

            value = this.Description + " Calibration data is stored in a text file, " + ...
                "as a 5x3 matrix containing scale factor in the first row, misalignment from the second to forth row, " + ...
                "and offset in the last row.";
        end

        function data = apply(this, data, ~)
            data{:, ["x", "y", "z"]} = this.applyCalibration(data{:, ["x", "y", "z"]});
        end
    end

    methods (Hidden)

        function calibratedData = applyCalibration(this, uncalibratedData)

            arguments (Input)
                this
                uncalibratedData (:, 3) double
            end

            arguments (Output)
                calibratedData (:, 3) double
            end

            [scale, misalignment, offset] = this.readCalibrationData();
            calibratedData = ((scale .* uncalibratedData) * misalignment) + offset;
        end
    end

    methods (Access = private)

        function [scale, misalignment, offset] = readCalibrationData(this)

            arguments (Output)
                scale (1, 3) double
                misalignment (3, 3) double
                offset (1, 3) double
            end

            data = readmatrix(this.CalibrationFile);

            scale = data(1, :);
            misalignment = data(2:4, :);
            offset = data(5, :);
        end
    end
end
