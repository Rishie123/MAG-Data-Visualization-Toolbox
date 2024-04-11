classdef ScienceCDF < mag.io.in.ICDF
% SCIENCECDF Format science data for CDF import.

    methods

        function data = initializeOutput(~)
            data = mag.Instrument();
        end

        function addToOutput(this, data, rawData)


        end
    end
end
