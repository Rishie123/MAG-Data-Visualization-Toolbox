function plan = buildfile()
% BUILDFILE File invoked by automated build.

    % Create a plan from task functions.
    plan = buildplan();

    % Add the "check" task to identify code issues.
    sourceFolders = "src";

    plan("check") = matlab.buildtool.tasks.CodeIssuesTask(sourceFolders, ...
        IncludeSubfolders = true);

    % Add the "test" task to run tests.
    testFolder = "tests";

    plan("test") = matlab.buildtool.tasks.TestTask(testFolder, ...
        SourceFiles = sourceFolders, ...
        IncludeSubfolders = true, ...
        TestResults = fullfile("artifacts/results.xml"), ...
        CodeCoverageResults = fullfile("artifacts/coverage.xml"));

    % Add the "package" task to create toolbox.
    plan("package") = mag.buildtool.task.PackageTask(Description = "Package code into toolbox", ...
        ToolboxProject = "MAGDataVisualizationToolbox.prj", ...
        ToolboxPath = fullfile("artifacts/MAG Data Visualization.mltbx"));

    % Add the "clean" task to delete output of all tasks.
    plan("clean") = matlab.buildtool.tasks.CleanTask();

    % Make sure tasks run by default.
    plan.DefaultTasks = ["check", "test"];
end
