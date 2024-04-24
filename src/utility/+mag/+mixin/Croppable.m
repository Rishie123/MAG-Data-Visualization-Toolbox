classdef (Abstract, HandleCompatible) Croppable
% CROPPABLE Interface adding support for cropping of data.

    methods (Abstract)

        % CROP Crop data based on selected filter.
        crop(this, timeFilter)
    end

    methods (Hidden, Sealed, Static)

        function mustBeTimeFilter(value)
        % MUSTBETIMEFILTER Validate that input value is of supported type
        % and format for cropping.

            mustBeA(value, ["duration", "timerange", "withtol"]);

            if isduration(value)

                if ~(isscalar(value) || (isvector(value) && isequal(numel(value), 2)))
                    throwAsCaller(MException("", "Time filter of type ""duration"" must have one or two elements."));
                end
            else

                if ~isscalar(value)
                    throwAsCaller(MException("", "Time filter of type ""%s"" must have one or two elements.", class(value)));
                end
            end
        end

        function timePeriod = convertToTimeSubscript(timeFilter, time)
        % CONVERTTOTIMESUBSCRIPT Convert to subscript that can be used for
        % timetable cropping.

            arguments (Input)
                timeFilter {mag.mixin.Croppable.mustBeTimeFilter}
                time datetime {mustBeVector(time, "allow-all-empties")}
            end

            arguments (Output)
                timePeriod (1, 1) {mustBeA(timePeriod, ["timerange", "withtol"])}
            end

            if isduration(timeFilter)

                if isscalar(timeFilter)

                    if timeFilter >= 0
                        timePeriod = timerange(min(time) + timeFilter, max(time), "closed");
                    else
                        timePeriod = timerange(min(time), max(time) + timeFilter, "closed");
                    end
                else
                    timePeriod = timerange(min(time) + timeFilter(1), min(time) + timeFilter(2), "closed");
                end
            elseif isa(timeFilter, "timerange") || isa(timeFilter, "withtol")
                timePeriod = timeFilter;
            end
        end
    end
end
