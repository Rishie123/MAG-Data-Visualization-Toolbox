classdef Settings < mag.mixin.SetGet
% SETTINGS Definition of import options.

    properties
        % FORMAT Import format.
        Format (1, 1) mag.io.in.Format = mag.io.in.ScienceCSV()
        % OUTPUT Already initialized output object.
        Output
        % PERFILEPROCESSING Processing to apply to each file.
        PerFileProcessing (1, :) mag.process.Step = mag.process.Step.empty()
        % WHOLEDATAPROCESSING Processing to apply to data as a whole.
        WholeDataProcessing (1, :) mag.process.Step = mag.process.Step.empty()
    end

    methods

        function this = Settings(options)

            arguments
                options.?mag.io.in.Settings
            end

            this.assignProperties(options)
        end
    end
end
