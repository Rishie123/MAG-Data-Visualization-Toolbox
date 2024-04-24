classdef HK < mag.meta.Data
% HK Description of MAG housekeeping data.

    properties
        % TYPE Type of HK data.
        Type string {mustBeScalarOrEmpty, mustBeMember(Type, ["PROCSTAT", "PW", "SID15", "STATUS"])}
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
