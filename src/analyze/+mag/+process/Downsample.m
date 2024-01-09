classdef Downsample < mag.process.Step
% DOWNSAMPLE Reduce data points by matching the desired frequency.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % FREQUENCY Desired frequency of output data.
        TargetFrequency (1, 1) double {mustBePositive} = 2
    end

    methods

        function this = Downsample(options)

            arguments
                options.?mag.process.Downsample
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = string.empty();
        end

        function value = get.Description(~)
            value = string.empty();
        end

        function value = get.DetailedDescription(this)
            value = this.Description;
        end

        function data = apply(this, data, metaData) %#ok<INUSD>

        end
    end

    methods (Hidden)

        function decimatedData = downsample(this, data)

            arguments (Input)
                this
                data timetable
            end

            arguments (Output)
                decimatedData timetable
            end

            % Determine filter coefficients.
            actualFrequency = 1 / mode(seconds(diff(data.(data.Properties.DimensionNames{1}))));

            decimationFactor = actualFrequency / this.TargetFrequency;
            assert(round(decimationFactor) == decimationFactor, "Calculated decimation factor (%.3f) must be an integer.", decimationFactor);

            fir1 = ones(1, decimationFactor) / decimationFactor;
            fir2 = conv(fir1, fir1);

            % Filter data.
            time = data.(data.Properties.DimensionNames{1});
            field = data.Variables;

            field = filter(fir2, 1, field);

            time = downsample(time, decimationFactor);
            field = downsample(field, decimationFactor);

            % Create output.
            decimatedData = array2timetable(field, RowTimes = time, ...
                DimensionNames = data.Properties.DimensionNames, VariableNames = data.Properties.VariableNames);
        end
    end
end
