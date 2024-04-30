classdef (Abstract, HandleCompatible) Signal
% SIGNAL Interface adding support for common signal operations.

    methods (Abstract)

        % RESAMPLE Resample data to the specified frequency.
        resample(this, targetFrequency)

        % DOWNSAMPLE Downsample data to the specified frequency.
        downsample(this, targetFrequency)
    end
end
