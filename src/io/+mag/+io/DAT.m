classdef DAT < mag.io.Type
% DAT Import/Export MAG data to/from DAT.

    properties (Constant)
        Extension = ".dat"
    end

    properties
        % VARIABLES Select variables to export.
        Variables (1, :) string = ["x", "y", "z"]
    end

    methods

        function this = DAT(options)

            arguments
                options.?mag.io.DAT
            end

            this.assignProperties(options);
        end
    end

    methods

        function data = import(~, ~) %#ok<STOUT>
            error("Unsupported import from DAT.");
        end

        function export(this, data, ~)

            arguments
                this
                data (1, 2) cell
                ~
            end

            sensors = ["Primary", "Secondary"];
            [path, name, extension] = fileparts(this.ExportFileName);

            for s = 1:numel(sensors)
                writematrix(data{s}{:, this.Variables}, fullfile(path, name + " " + sensors(s) + extension), Delimiter = "tab");
            end
        end
    end
end

