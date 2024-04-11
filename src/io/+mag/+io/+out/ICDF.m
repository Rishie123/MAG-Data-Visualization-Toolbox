classdef (Abstract) ICDF < mag.io.out.IFormat
% ICDF Interface for CDF export format providers.

    properties
        % SKELETONLOCATION Location of skeleton files.
        SkeletonLocation (1, 1) string {mustBeFolder}
        % LEVEL Data processing level.
        Level (1, 1) string {mag.validator.mustMatchRegex(Level, "L[0-2]\w?")}
        % VERSION CDF skeleton version.
        Version (1, 1) string
    end

    methods (Abstract)

        % GETSKELETONFILE Get skeleton file name containing meta data.
        sensor = getSkeletonFileName(this)

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
