classdef (Abstract) HK < mag.TimeSeries & matlab.mixin.CustomDisplay
% HK Class containing MAG housekeeping data.

    methods

        function this = HK(hkData, metaData)

            arguments
                hkData timetable
                metaData (1, 1) mag.meta.HK
            end

            this.Data = hkData;
            this.MetaData = metaData;
        end

        function resample(this, targetFrequency)

            arguments
                this
                targetFrequency (1, 1) double
            end

            if ~isempty(this.Data)
                this.Data = retime(this.Data, "regular", "linear", TimeStep = seconds(1 / targetFrequency));
            end
        end

        function downsample(this, targetFrequency)

            arguments
                this
                targetFrequency (1, 1) double
            end

            this.resample(targetFrequency);
        end
    end

    methods (Sealed)

        function crop(this, timeFilter)

            arguments
                this
                timeFilter (1, 1) timerange
            end

            for i = 1:numel(this)
                this(i).Data = this(i).Data(timeFilter, :);
            end
        end

        function hkType = getHKType(this, type)
        % GETHKTYPE Get specific type of HK. Default is power HK.

            arguments
                this
                type (1, 1) string {mustBeMember(type, ["PROCSTAT", "PW", "SID15", "STATUS"])} = "PW"
            end

            if ~isempty(this)

                hkMetaData = [this.MetaData];
                hkType = this([hkMetaData.Type] == type);
            else
                hkType = mag.HK.empty();
            end
        end
    end

    methods (Sealed, Access = protected)

        function header = getHeader(this)

            if isscalar(this)

                if ~isempty(this.MetaData) && ~isempty(this.MetaData.Type)
                    tag = char(compose("%s", this.MetaData.Type));
                else
                    tag = char.empty();
                end

                className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
                header = ['  ', className, ' HK (', tag, ') with properties:'];
            else
                header = getHeader@matlab.mixin.CustomDisplay(this);
            end
        end

        function groups = getPropertyGroups(this)
            groups = getPropertyGroups@matlab.mixin.CustomDisplay(this);
        end

        function footer = getFooter(this)
            footer = getFooter@matlab.mixin.CustomDisplay(this);
        end

        function displayScalarObject(this)
            displayScalarObject@matlab.mixin.CustomDisplay(this);
        end

        function displayNonScalarObject(this)
            displayNonScalarObject@matlab.mixin.CustomDisplay(this);
        end

        function displayEmptyObject(this)
            displayEmptyObject@matlab.mixin.CustomDisplay(this);
        end

        function displayScalarHandleToDeletedObject(this)
            displayScalarHandleToDeletedObject@matlab.mixin.CustomDisplay(this);
        end
    end
end
