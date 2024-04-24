classdef CDFSettings < mag.mixin.SetGet
% CDFSETTINGS Settings for import/export of CDF files.

    properties
        % TIMESTAMP Name of timestamp property in CDF file.
        Timestamp (1, 1) pattern = "EPOCH"
        % FIELD Name of field property in CDF file.
        Field (1, 1) pattern = "B_MAG" + wildcardPattern() + "_URF"
        % RANGE Name of range property in CDF file.
        Range (1, 1) pattern = "VECTOR_RANGE"
    end

    methods

        function this = CDFSettings(options)

            arguments
                options.?mag.io.CDFSettings
            end

            this.assignProperties(options)
        end
    end
end
