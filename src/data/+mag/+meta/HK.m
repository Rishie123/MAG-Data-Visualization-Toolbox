classdef HK < mag.meta.Data
% HK Description of MAG housekeeping data.

    properties (Constant)
        MetaDataFilePattern (1, 1) string = "idle_export_\w+.MAG_HSK_(?<type>\w+)_(?<date>\d+)_(?<time>\w+).(?<extension>\w+)"
    end

    properties
        % TYPE Type of HK data.
        Type string {mustBeScalarOrEmpty, mustBeMember(Type, ["PW", "SID15", "STATUS"])}
    end

    methods

        function this = HK(options)

            arguments
                options.?mag.meta.HK
            end

            this.assignProperties(options);
        end
    end
end
