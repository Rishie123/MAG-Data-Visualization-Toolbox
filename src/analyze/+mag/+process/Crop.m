classdef Crop < mag.process.Step
% CROP Remove some data points at the beginning of file.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % NUMBEROFVECTORS Number of vectors to crop at beginning.
        NumberOfVectors (1, 1) double
    end

    methods

        function this = Crop(options)

            arguments
                options.?mag.process.Crop
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Crop File Head";
        end

        function value = get.Description(~)
            value = "Crop data at the beginning of a file.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description + " " + this.NumberOfVectors + " vector(s) are cropped.";
        end

        function data = apply(this, data, ~)

            arguments
                this
                data table
                ~
            end

            data(1:this.NumberOfVectors, :) = [];
        end
    end
end
