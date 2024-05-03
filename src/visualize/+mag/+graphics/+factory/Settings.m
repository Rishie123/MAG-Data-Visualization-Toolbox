classdef Settings < mag.mixin.SetGet
% SETTINGS Graphics generation settings.

    properties
        Name (1, 1) string = "MAG Plot"
        Title string {mustBeScalarOrEmpty} = string.empty()
        Arrangement (1, 2) double = zeros(1, 2)
        GlobalLegend (1, :) string = string.empty()
        LinkXAxes (1, 1) logical = false
        LinkYAxes (1, 1) logical = false
        TileIndexing (1, 1) string {mustBeMember(TileIndexing, ["columnmajor", "rowmajor"])} = "rowmajor"
        WindowState (1, 1) string {mustBeMember(WindowState, ["normal", "maximized", "minimized", "fullscreen"])} = "normal"
        ShowVersion (1, 1) logical = false
        Visible (1, 1) logical = get(groot(), "DefaultFigureVisible")
    end

    methods

        function this = Settings(options)

            arguments
                options.?mag.graphics.factory.Settings
            end

            this.assignProperties(options)
        end
    end
end
