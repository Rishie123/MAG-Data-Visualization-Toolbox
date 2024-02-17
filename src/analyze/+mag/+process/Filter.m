classdef Filter < mag.process.Step
% FILTER Remove data points at events, such as mode and range changes.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % ONRANGECHANGE How many vectors to remove when range changes.
        OnRangeChange (1, 2) {mustBeA(OnRangeChange, ["double", "duration"])} = zeros(1, 2)
        % ONMODECHANGE How many vectors to remove when mode changes.
        OnModeChange (1, 2) {mustBeA(OnModeChange, ["double", "duration"])} = zeros(1, 2)
    end

    methods

        function this = Filter(options)

            arguments
                options.?mag.process.Filter
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Filter Out Data";
        end

        function value = get.Description(~)
            value = "Filter out data after mode and range change events.";
        end

        function value = get.DetailedDescription(this)

            value = this.Description + " After said events, onboard filtering " + ...
                "needs time to adjust, thus some data points are dropped for display purposes. " + ...
                "For range changes, " + string(this.OnRangeChange(1)) + " before and " + string(this.OnRangeChange(2)) + ...
                " after are dropped, and for mode changes, " + string(this.OnModeChange(1)) + " before and " + ...
                string(this.OnModeChange(2)) + " after are dropped.";
        end

        function data = apply(this, data, ~)

            arguments
                this (1, 1) mag.process.Filter
                data timetable
                ~
            end

            [startTime, endTime] = bounds(data.t);

            events = data.Properties.Events;
            events = events(timerange(startTime, endTime, "closed"), :);

            % Filter data points at mode changes.
            if ~isequal(this.OnModeChange, zeros(1, 2))
                data = this.cropDataWithRange(events, data, "DataFrequency", this.OnModeChange);
            end

            % Filter duration at range changes.
            if ~isequal(this.OnRangeChange, zeros(1, 2))
                data = this.cropDataWithRange(events, data, "Range", this.OnRangeChange);
            end

            % Filter out between config and ramp mode.
            % Ramp mode is surrounded by two config modes. Remove data from
            % the first to the last config.
            locConfig = contains(events.Label, "Config");
            idxConfig = find(locConfig);

            if (nnz(locConfig) == 2) && any(contains([events.Label(idxConfig(1):idxConfig(end))], "Ramp"))
                data{timerange(events.Time(idxConfig(1)), events.Time(idxConfig(end)), "closed"), "quality"} = false;
            end
        end
    end

    methods (Static, Access = private)

        function data = cropDataWithRange(events, data, name, range)

            dt = mode(diff(data.t));
            locEvent = [true; diff(events.(name)) ~= 0];

            for t = events.Time(locEvent)'

                if isa(range, "duration")
                    data{timerange(t + range(1), t + range(2), "closed"), "quality"} = false;
                else

                    tEvent = data(withtol(t, dt), :).t;

                    if isempty(tEvent)
                        continue;
                    elseif isscalar(tEvent)
                        idxTime = find(data.t == tEvent);
                    else
                        [~, idxTime] = min(abs(data.t - t));
                    end

                    r = range(1):range(2);
                    r(r == 0) = [];
                    r(r > 0) = r(r > 0) - 1;

                    idxRemove = idxTime + r;
                    idxRemove(idxRemove < 1) = [];

                    data{idxRemove, "quality"} = false;
                end
            end
        end
    end
end
