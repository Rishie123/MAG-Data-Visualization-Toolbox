classdef (Abstract) IMAPScienceCDF < mag.io.format.Data
% CDF Interface for CDF data format providers.

    properties
        Level
    end

    methods

        function sensor = getSensor(this)

        end

        function globalAttributes = getGlobalAttributes(this, cdfInfo)

            globalAttributes = cdfInfo.GlobalAttributes;

            globalAttributes.Logical_source = sprintf('imap_L1b_mag%s', lower(data.MetaData.Mode{:}(1)));
            globalAttributes.Logical_file_id = char(this.ExportFileName);
            globalAttributes.Logical_source_description = sprintf('IMAP Magnetometer Level %s %s Mode Data in %s coordinates.', this.Level, data.MetaData.Mode, "S/C");
            globalAttributes.Generation_date = char(datetime("now", Format = "yyyy-MM-dd'T'HH:mm:SS"));
            globalAttributes.Software_version = char(metaData.ASW);

            globalAttributes.Distribution = 'Internal to Imperial College London';
            globalAttributes.Rules_of_use = 'Not for science use or publication';
        end

        function variableAttributes = getVariableAttributes(this, cdfInfo)
        end

        function variableDataTypes = getVariableDataType(this, cdfInfo)
        end

        function variableList = getVariableList(this, cdfInfo)
        end
    end
end
