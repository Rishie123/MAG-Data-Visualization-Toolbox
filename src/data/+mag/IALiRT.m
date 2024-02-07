classdef IALiRT < matlab.mixin.Copyable & mag.mixin.SetGet & mag.mixin.Croppable
% IALIRT Class containing MAG I-ALiRT data.

    properties (GetAccess = public, SetAccess = private)
        % PRIMARY Primary I-ALiRT data.
        Primary mag.Science {mustBeScalarOrEmpty}
        % SECONDARY Secondary I-ALiRT data.
        Secondary mag.Science {mustBeScalarOrEmpty}
    end

    methods

        function this = IALiRT(primaryData, secondaryData)

            arguments
                primaryData (1, 1) mag.Science
                secondaryData (1, 1) mag.Science
            end

            this.Primary = primaryData;
            this.Secondary = secondaryData;
        end

        function crop(this, timeFilter)

            this.Primary.crop(timeFilter);
            this.Secondary.crop(timeFilter);
        end
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@matlab.mixin.Copyable(this);

            copiedThis.Primary = copy(this.Primary);
            copiedThis.Secondary = copy(this.Secondary);
        end
    end
end
