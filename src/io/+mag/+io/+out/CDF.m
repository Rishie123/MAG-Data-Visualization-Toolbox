classdef (Abstract) CDF < mag.io.out.Format
% CDF Interface for CDF export format providers.

    properties (Constant)
        Extension = ".cdf"
    end

    properties
        % SKELETONLOCATION Location of skeleton files.
        SkeletonLocation (1, 1) string {mustBeFolder}
        % LEVEL Data processing level.
        Level (1, 1) string {mag.validator.mustMatchRegex(Level, "L[0-2]\w?")}
        % VERSION CDF skeleton version.
        Version (1, 1) string
    end

    methods

        function exportData = convertToExportFormat(~, data)
            exportData = data;
        end

        function write(this, fileName, exportData)

            assert(exist("spdfcdfinfo", "file"), "SPDF CDF Toolbox needs to be installed.");

            cdfInfo = spdfcdfinfo(this.getSkeletonFileName());

            spdfcdfwrite(fileName, ...
                this.getVariableList(cdfInfo, exportData), ...
                'GlobalAttributes', this.getGlobalAttributes(cdfInfo), ...
                'VariableAttributes', this.getVariableAttributes(cdfInfo, exportData), ...
                'ConvertDatenumToTT2000', true, ...
                'WriteMode', 'overwrite', ...
                'Format', 'singlefile', ...
                'RecordBound', this.getRecordBound(cdfInfo), ...
                'CDFCompress', 'gzip.6',...
                'Checksum', 'MD5', ...
                'VarDatatypes', this.getVariableDataType(cdfInfo));
        end
    end

    methods (Abstract, Access = protected)

        % GETSKELETONFILE Get skeleton file name containing meta data.
        fileName = getSkeletonFileName(this)

        % GETGLOBALATTRIBUTES Retrieve global attributes of CDF file.
        globalAttributes = getGlobalAttributes(this, cdfInfo)

        % GETVARIABLEATTRIBUTES Retrieve variable attributes of CDF file.
        variableAttributes = getVariableAttributes(this, cdfInfo, data)

        % GETVARIABLEDATATYPE Retrieve variable data types of CDF file.
        variableDataTypes = getVariableDataType(this, cdfInfo)

        % GETRECORDBOUND Retrieve record bound of CDF file.
        recordBound = getRecordBound(this, cdfInfo)

        % GETVARIABLELIST Retrieve variable list of CDF file.
        variableList = getVariableList(this, cdfInfo, data)
    end
end
