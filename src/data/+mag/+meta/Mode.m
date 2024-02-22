classdef Mode < uint8
% MODE Enumeration for mode type.

    enumeration
        % HYBRID Sensor in more than one mode.
        Hybrid (0)
        % NORMAL Normal mode.
        Normal (1)
        % BURST Burst mode.
        Burst (2)
        % IALIRT IALiRT mode.
        IALiRT (3)
    end
end
