function v = version()
% VERSION Get MAG software version, compliant with Semanting Versioning
% 2.0.0.

    arguments (Output)
        v (1, 1) string {mustBeVersion}
    end

    persistent ver;

    if isempty(ver)

        location = fileparts(mfilename("fullpath"));
        data = fileread(fullfile(location, "../../../.github/workflows/matlab.yml"));

        match = regexp(data, "VERSION: ""(?<version>\d+\.\d+\.\d+)""", "once", "names");

        if isempty(match)
            ver = "";
        else
            ver = match.version;
        end
    end

    v = ver;
end

function mustBeVersion(value)

    if ~matches(value, regexpPattern("\d+\.\d+\.\d+"))
        error("Version must be compliant with Semantic Versioning 2.0.0.");
    end
end
