classdef IALiRT < matlab.mixin.Copyable & mag.mixin.SetGet & mag.mixin.Crop
% IALIRT Class containing MAG I-ALiRT data.

    properties
        % SCIENCE Science data.
        Science (1, :) mag.Science
    end

    properties (Dependent)
        % HASDATA Boolean denoting whether data is present.
        HasData (1, 1) logical
        % HASSCIENCE Logical denoting whether instrument has science data.
        HasScience (1, 1) logical
        % PRIMARY Primary science data.
        Primary mag.Science {mustBeScalarOrEmpty}
        % SECONDARY Secondary science data.
        Secondary mag.Science {mustBeScalarOrEmpty}
    end

    methods

        function this = IALiRT(options)

            arguments
                options.?mag.IALiRT
            end

            this.assignProperties(options);
        end

        function hasData = get.HasData(this)
            hasData = this.HasScience;
        end

        function hasData = get.HasScience(this)
            hasData = ~isempty(this.Science) && all([this.Science.HasData]);
        end

        function primary = get.Primary(this)
            primary = this.Science.select("Primary");
        end

        function secondary = get.Secondary(this)
            secondary = this.Science.select("Secondary");
        end

        function crop(this, primaryFilter, secondaryFilter)

            arguments
                this (1, 1) mag.IALiRT
                primaryFilter
                secondaryFilter = primaryFilter
            end

            this.Primary.crop(primaryFilter);
            this.Secondary.crop(secondaryFilter);
        end
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@matlab.mixin.Copyable(this);
            copiedThis.Science = copy(this.Science);
        end
    end
end
