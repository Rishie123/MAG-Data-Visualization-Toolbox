function tf = useParallel()
% USEPARALLEL Determine whether to use Parallel Computing Toolbox to
% process data. Does not require Parallel Computing Toolbox to run.

    tf = license("test", "Distrib_Computing_Toolbox") && ~isempty(gcp("nocreate"));
end
