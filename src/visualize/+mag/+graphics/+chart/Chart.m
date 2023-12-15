classdef (Abstract) Chart < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% CHART Definition of visualization of MAG science and HK data.

    properties
        % XVARIABLE Name of variable plotted on x-axis. Default is time.
        XVariable string {mustBeScalarOrEmpty}
        % YVARIABLES Name of variables plotted on y-axis.
        YVariables (1, :) string
        % FILTERS Filter x- and y-axis variables.
        Filters logical = logical.empty()
    end

    methods (Abstract)

        % PLOT Plot data on the given graphics element.
        graph = plot(this, data, axes, layout)
    end

    methods (Access = protected)

        function filteredData = filterData(this, data)
        % FILTERDATA Filter data based on specified filter.

            if isempty(this.Filters)

                % No filtering.
                filteredData = data;
            elseif (size(this.Filters, 2) == 1) && (numel(this.YVariables) >= 1)

                % Same filtering for each y-axis variable.
                filteredData = data(this.Filters, :);
            elseif (size(this.Filters, 2) == numel(this.YVariables))

                % Different filtering for each y-axis variable.
                filteredData = cell(1, numel(this.YVariables));

                for i = 1:numel(this.YVariables)
                    filteredData{i} = data(this.Filters(:, i), :);
                end
            else
                error("Mismatch between filter and y-axis variable selection.");
            end
        end

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
