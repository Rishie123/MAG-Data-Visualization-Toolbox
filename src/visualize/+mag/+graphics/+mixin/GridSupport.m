classdef (Abstract, HandleCompatible) GridSupport
% GRIDSUPPORT Add support for grid customization for an axis.

    properties
        % GRID Logical denoting whether to add a grid.
        Grid (1, 1) logical = true
    end

    methods (Access = protected)

        function applyGridStyle(this, axes)
        % APPLYGRIDSTYLE Apply specified style to an axis, to customize
        % grid appearance.

            grid(axes, string(matlab.lang.OnOffSwitchState(this.Grid)));
        end
    end
end
