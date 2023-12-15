classdef (Abstract) Step < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% STEP Abstract class to capture a processing step for MAG science data.

    properties (Abstract, Dependent)
        % NAME Display name of processing step.
        Name (1, 1) string
        % DESCRIPTION Brief description of processing step functionality.
        Description (1, 1) string
        % DETAILEDDESCRIPTION Detailed description of processing step
        % functionality.
        DetailedDescription (1, 1) string
    end

    methods (Abstract)

        % APPLY Apply processing step.
        data = apply(this, data, metaData)
    end

    methods (Static, Access = protected)

        function sequence = correctSequence(sequence)
        % CORRECTSEQUENCE Find where sequence number restarts, and remove
        % discountinuity.

            deltaSequence = diff(sequence);
            idxSequenceReset = find(deltaSequence < 0);

            for i = idxSequenceReset'
                sequence(i+1:end) = 1 + (sequence(i) - sequence(i + 1)) + sequence(i+1:end);
            end
        end
    end
end
