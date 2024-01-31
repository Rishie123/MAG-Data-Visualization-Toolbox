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
        % If no name is provided, use independent variable.

            arguments
                this
                data {mustBeA(data, ["mag.Data", "tabular"])}
            end

            if isempty(this.XVariable)

                if isa(data, "tabular")
                    xData = data.(data.Properties.DimensionNames{1});
                else
                    xData = data.IndependentVariable;
                end
            else
                xData = data.(this.XVariable);
            end
        end

        function yData = getYData(this, data)
        % GETYDATA Retrieve y-axis data, based on selected variable names.
        % If no name is provided, use dependent variables.

            arguments
                this
                data {mustBeA(data, ["mag.Data", "tabular"])}
            end

            if isempty(this.YVariables)

                if isa(data, "tabular")
                    yData = data.(data.Properties.DimensionNames{2});
                else
                    yData = data.DependentVariables;
                end
            else

                if isa(data, "tabular")
                    yData = data{:, this.YVariables};
                else
                    yData = data.get(this.YVariables);
                end
            end
        end
    end
end
