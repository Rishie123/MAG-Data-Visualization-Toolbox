classdef (Abstract) Chart < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% CHART Definition of visualization of MAG science and HK data.

    properties
        % XVARIABLE Name of variable plotted on x-axis. Default is time.
        XVariable string {mustBeScalarOrEmpty}
        % YVARIABLES Name of variables plotted on y-axis.
        YVariables (1, :) string
    end

    methods (Abstract)

        % PLOT Plot data on the given graphics element.
        graph = plot(this, data, axes, layout)
    end

    methods (Access = protected)

        function xData = getXData(this, data)
        % GETXDATA Retrieve x-axis data, based on selected variable name.
        % If no name is provided, use time.

            if isempty(this.XVariable)
                xData = data.(data.Properties.DimensionNames{1});
            else
                xData = data.(this.XVariable);
            end
        end
    end
end
