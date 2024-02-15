classdef (Abstract) Action < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% ACTION Base class for all actions to manipulate data before plotting.

    methods (Sealed)

        function plottableData = applyAll(this, originalData)
        % APPLYALL Apply all operations.

            plottableData = arrayfun(@(o) o.apply(originalData), this, UniformOutput = false);
            plottableData = [plottableData{:}];
        end
    end

    methods (Abstract)

        % APPLY Apply operation to data.
        plottableData = apply(this, originalData)
    end

    methods (Static, Access = protected)

        function value = getVariables(data, variableNames)
        % GETVARIABLES Get variable values from tabular or "mag.Data".

            if isa(data, "tabular")
                value = data{:, variableNames};
            else
                value = data.get(variableNames);
            end
        end
    end
end
