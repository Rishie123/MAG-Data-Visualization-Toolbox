classdef (Abstract) CDF < mag.io.format.Data
% CDF Interface for CDF data format providers.

    methods (Abstract)

        % GETSENSOR
        sensor = getSensor(this)

        % GETGLOBALATTRIBUTES
        globalAttributes = getGlobalAttributes(this, cdfInfo)

        % GETVARIABLEATTRIBUTES
        variableAttributes = getVariableAttributes(this, cdfInfo)

        % GETVARIABLEDATATYPE
        variableDataTypes = getVariableDataType(this, cdfInfo)

        % GETVARIABLELIST
        variableList = getVariableList(this, cdfInfo)
    end
end
