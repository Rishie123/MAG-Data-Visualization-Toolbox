classdef Result < mag.Data
% SCIENCE Class containing MAG science data.

    properties
        Data
    end

    properties (Dependent)
        IndependentVariable
        DependentVariables
    end

    methods

        function this = Result(resultData)

            arguments
                resultData
            end

            this.Data = resultData;
        end
    end

    methods (Sealed)

        function tabularThis = tabular(this)
        % TABULAR Convert data to tabular.

            tabularThis = this.Data;
        end

        function tableThis = table(this)
        % TABLE Convert data to table.

            tableThis = this.Data;
        end
    end
end
