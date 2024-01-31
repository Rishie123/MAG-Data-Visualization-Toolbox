classdef (Abstract, HandleCompatible, Hidden) MarkerSupport
% MARKERSUPPORT Add support for marker customization for a chart.

    properties
        % MARKER Marker symbol.
        Marker (1, 1) string = "none"
        % MARKERSIZE Marker size.
        MarkerSize (1, 1) double = 10
        % MARKERFACE Marker face color option. "flat" means filled marker.
        MarkerColor {mag.graphics.mixin.mustBeColor} = "none"
    end

    properties (Dependent, Access = protected)
        % MARKERSTYLE Marker style options to apply to graph constructor.
        MarkerStyle (1, :) cell
    end

    methods

        function style = get.MarkerStyle(this)

            style = {"Marker", this.Marker, ...
                "MarkerSize", this.MarkerSize, ...
                "MarkerEdgeColor", this.MarkerColor, ...
                "MarkerFaceColor", this.MarkerColor};
        end
    end

    methods (Access = protected)

        function applyMarkerStyle(this, graph)
        % APPLYMARKERSTYLE Apply specified style to a graph, to customize
        % marker appearance.

            for i = 1:numel(graph)

                set(graph(i), ...
                    Marker = this.Marker, ...
                    MarkerSize = this.MarkerSize, ...
                    MarkerFaceColor = this.MarkerColor);
            end
        end
    end
end
