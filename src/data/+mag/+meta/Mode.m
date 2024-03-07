classdef Mode < uint8
% MODE Enumeration for mode type.

    enumeration
        % CONFIG Configuration mode.
        Config (0)
        % NORMAL Normal mode.
        Normal (1)
        % BURST Burst mode.
        Burst (2)
        % IALIRT IALiRT mode.
        IALiRT (3)
        % HYBRID Sensor in more than one mode.
        Hybrid (4)
    end
end
