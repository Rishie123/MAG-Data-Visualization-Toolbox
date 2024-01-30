classdef Bubblechart < mag.graphics.chart.Chart
% BUBBLECHART Definition of chart of "bubblechart" type.

    properties
        % SVARIABLES Name of variables denoting size.
        SVariables (1, :) string
        % CVARIABLES Name of variables denoting color.
        CVariables (1, :) string
    end

    methods

        function this = Bubblechart(options)

            arguments
                options.?mag.graphics.chart.Bubblechart
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, ~)

            arguments (Input)
                this
                data tabular
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            args = {this.getXData(data), data{:, this.YVariables}, data{:, this.SVariables}};

            if ~isempty(this.CVariables)
                args = [args, {data{:, this.CVariables}}];
            end

            graph = bubblechart(axes, args{:});
        end
    end
end
