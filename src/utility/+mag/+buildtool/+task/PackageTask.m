classdef (Sealed) PackageTask < matlab.buildtool.Task
% PACKAGETASK Package code into toolbox.

    properties (TaskInput)
        % TOOLBOXPROJECT Toolbox configuration project.
        ToolboxProject string {mustBeScalarOrEmpty, mustBeFile}
        % TOOLBOXPATH Full path to toolbox to package into.
        ToolboxPath string {mustBeScalarOrEmpty}
    end

    properties (Dependent, Hidden, TaskOutput, SetAccess = private)
        % TOOLBOXARTIFACT Toolbox packaged by task.
        ToolboxArtifact matlab.buildtool.io.File {mustBeScalarOrEmpty}
    end

    methods

        function task = PackageTask(options)

            arguments
                options.?mag.buildtool.task.PackageTask
            end

            for p = string(fieldnames(options))'
                task.(p) = options.(p);
            end
        end

        function value = get.ToolboxArtifact(task)
            value = matlab.buildtool.io.File(task.ToolboxPath);
        end
    end

    methods (Hidden, TaskAction)

        function packageToolbox(task, ~)
        % PACKAGETOOLBOX Package code into toolbox.

            matlab.addons.toolbox.packageToolbox(task.ToolboxProject, task.ToolboxPath);
        end
    end
end
