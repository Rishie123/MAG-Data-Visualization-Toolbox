classdef (Abstract, HandleCompatible) Croppable
% CROPPABLE Interface adding support for cropping of data.

    methods (Abstract)

        % CROP Crop data based on selected filter.
        crop(this, timeFilter)
    end
end
