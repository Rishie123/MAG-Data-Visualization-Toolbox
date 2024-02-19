classdef DateTime < mag.process.Step
% DATETIME Convert timestamp to datetime.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % TIMEVARIABLE Name of time variable.
        TimeVariable (1, 1) string = "t"
        % EPOCH Time offset to account for POSIX time starting on 1st Jan
        % 1970.
        Epoch (1, 1) double = mag.time.Constant.Epoch
        % FORMAT Time format.
        Format (1, 1) string = mag.time.Constant.Format
        % TIMEZONE Time zone of input data.
        TimeZone (1, 1) string = mag.time.Constant.TimeZone
    end

    methods

        function this = DateTime(options)

            arguments
                options.?mag.process.DateTime
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Date Time Conversion";
        end

        function value = get.Description(~)
            value = "Convert time from seconds since 1st January 2010, to MATLAB's |datetime| format.";
        end

        function value = get.DetailedDescription(this)

            value = this.Description + " Time is formatted according to """ + ...
                this.Format + """ format.";
        end

        function data = apply(this, data, ~)
            data.(this.TimeVariable) = this.convertToDateTime(data.(this.TimeVariable));
        end
    end

    methods (Hidden)

        function timeStamp = convertToDateTime(this, timeStamp)

            arguments (Input)
                this
                timeStamp (:, 1) double
            end

            arguments (Output)
                timeStamp (:, 1) datetime
            end

            timeStamp = datetime(this.Epoch + timeStamp, ConvertFrom = "posixtime", Format = this.Format, TimeZone = this.TimeZone);
        end
    end
end
