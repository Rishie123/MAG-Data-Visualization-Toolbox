classdef Range < mag.process.Step
% RANGE Apply scale factor based on range value.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties (Constant)
        ScaleFactors (1, 4) double = [2.13618, 0.072, 0.01854, 0.00453]
    end

    methods

        function value = get.Name(~)
            value = "Apply Range-Based Scaling";
        end

        function value = get.Description(~)
            value = "Apply scale factor based on range value.";
        end

        function value = get.DetailedDescription(this)

            value = this.Description + " Scale factors are " + join(compose("""%.5f""", this.ScaleFactors), ", ") + ...
                " for ranges 0 to 3, respectively.";
        end

        function data = apply(this, data, ~)
            data{:, ["x", "y", "z"]} = this.applyRange(data{:, ["x", "y", "z"]}, data.range);
        end
    end

    methods (Hidden)

        function unscaledData = applyRange(this, unscaledData, ranges)

            arguments (Input)
                this
                unscaledData (:, :) double
                ranges (:, 1) double
            end

            for sf = 0:3

                locScaleFactor = ranges == sf;
                unscaledData(locScaleFactor, :) = this.ScaleFactors(sf + 1) * unscaledData(locScaleFactor, :);
            end
        end
    end
end
