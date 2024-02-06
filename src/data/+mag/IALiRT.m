classdef IALiRT < mag.Data
% IALIRT Class containing MAG I-ALiRT data.

    properties (GetAccess = public, SetAccess = immutable)
        % PRIMARY Primary I-ALiRT data.
        Primary mag.Science {mustBeScalarOrEmpty}
        % SECONDARY Secondary I-ALiRT data.
        Secondary mag.Science {mustBeScalarOrEmpty}
    end

    methods

        function this = IALiRT(primaryData, secondaryData, metaData)

            arguments
                primaryData (1, 1) mag.Science
                secondaryData (1, 1) mag.Science
                metaData (1, 1) mag.meta.IALiRT
            end

            this.PrimaryData = primaryData;
            this.SecondaryData = secondaryData;
            this.MetaData = metaData;
        end
    end
end
