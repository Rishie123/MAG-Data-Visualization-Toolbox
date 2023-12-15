classdef (Abstract) Data < handle & matlab.mixin.Copyable & matlab.mixin.Heterogeneous & mag.mixin.SetGet
% DATA Abstract base class for MAG science and HK data.

    properties (GetAccess = public, SetAccess = protected)
        % METADATA Meta data.
        MetaData (1, :) mag.meta.Data
    end

    properties (Abstract, Dependent)
        % INDEPENDENTVARIABLE Independent variable of data.
        IndependentVariable (:, 1)
        % DEPENDENTVARIABLES Dependent variables of data.
        DependentVariables
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@matlab.mixin.Copyable(this);
            copiedThis.MetaData = copy(this.MetaData);
        end
    end
end
