classdef HK < mag.TimeSeries
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

            this.Data = retime(this.Data, "regular", "linear", TimeStep = seconds(1 / targetFrequency));
        end
    end

    methods (Sealed)

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
end
