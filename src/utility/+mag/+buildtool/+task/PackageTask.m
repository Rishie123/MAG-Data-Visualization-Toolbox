classdef (Sealed) PackageTask < matlab.buildtool.Task
% PACKAGETASK Package code into toolbox.

    properties (Constant, Access = private)
        ToolboxProject_ (1, 1) string = "MAGDataVisualizationToolbox.prj"
    end

    properties (TaskInput)
        % TOOLBOXTEMPLATE Toolbox configuration project template.
        ToolboxTemplate string {mustBeScalarOrEmpty, mustBeFile}
        % TOOLBOXVERSION Toolbox configuration project template.
        ToolboxVersion (1, 1) string = "1.0"
        % TOOLBOXPATH Full path to toolbox to package into.
        ToolboxPath string {mustBeScalarOrEmpty}
    end

    properties (Dependent, Hidden, TaskOutput, SetAccess = private)
        % TOOLBOXPROJECT Toolbox configuration project generated by task.
        ToolboxProject matlab.buildtool.io.File {mustBeScalarOrEmpty}
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

        function value = get.ToolboxProject(task)
            value = matlab.buildtool.io.File(task.ToolboxProject_);
        end

        function value = get.ToolboxArtifact(task)
            value = matlab.buildtool.io.File(task.ToolboxPath);
        end
    end

    methods (Hidden, TaskAction)

        function packageToolbox(task, ~, version)
        % PACKAGETOOLBOX Package code into toolbox.
            
            arguments
                task (1, 1) mag.buildtool.task.PackageTask
                ~
                version (1, 1) string = task.ToolboxVersion
            end

            % Read template and set version number.
            [~, fileName] = fileparts(task.ToolboxProject_);

            template = fileread(task.ToolboxTemplate);
            template = compose(template, task.ToolboxProject_, fileName, version);

            % Create project file.
            fileId = fopen(task.ToolboxProject_, "w");
            closeFile = onCleanup(@() fclose(fileId));

            fprintf(fileId, "%s", template{1});

            % Package toolbox.
            matlab.addons.toolbox.packageToolbox(task.ToolboxProject_, task.ToolboxPath);
        end
    end
end
