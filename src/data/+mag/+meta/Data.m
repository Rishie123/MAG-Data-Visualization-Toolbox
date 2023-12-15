classdef (Abstract) Data < matlab.mixin.Copyable & matlab.mixin.Heterogeneous & mag.mixin.SetGet
% DATA Description of MAG telemetry data.
%
% Includes description of which sensor, mode and frequency was used, and
% when the measurement started.

    properties
        % DESCRIPTION Description of MAG data.
        Description string {mustBeScalarOrEmpty}
        % TIMESTAMP Timestamp of meta data.
        Timestamp (1, 1) datetime = NaT(TimeZone = mag.process.DateTime.TimeZone)
    end

    methods

        function set.Timestamp(this, value)
            this.Timestamp = datetime(value, TimeZone = "local");
        end
    end

    methods (Sealed)

        function sortedThis = sort(this, varargin)
        % SORT Override default sorting algorithm.

            [~, idxSort] = sort([this.Timestamp], varargin{:});
            sortedThis = this(idxSort);
        end

        function structThis = struct(this)
        % STRUCT Convert class to struct containing only public properties.

            metaClasses = metaclass(this);

            for mc = metaClasses

                for mp = mc.PropertyList'

                    if ~mp.Constant && isequal(mp.GetAccess, "public") && isequal(mp.SetAccess, "public")
                        structThis.(mp.Name) = this.(mp.Name);
                    end
                end

                metaClasses = [metaClasses, mc.SuperclassList]; %#ok<AGROW>
            end
        end

        function value = getDisplay(this, property, alternative)
        % GETDISPLAY Get property value for display purposes. If object is
        % not scalar, a unanimous value is returned, or an alternative
        % (default is missing).

            arguments
                this
                property (1, 1) string
                alternative = missing()
            end

            values = [this.(property)];

            if isscalar(this) || isempty(values)

                value = values;
                return;
            end

            uniqueValues = unique(values);

            if isscalar(uniqueValues)
                value = uniqueValues;
            else

                if ismissing(alternative)
                    value = feval(class(values), alternative);
                else
                    value = alternative;
                end
            end
        end
    end
end
