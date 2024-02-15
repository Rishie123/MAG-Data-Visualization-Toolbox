function v = version()
% VERSION Get MAG software version, compliant with Semanting Versioning
% 2.0.0.

    arguments (Output)
        v (1, 1) string {mustBeVersion}
    end

    persistent ver;

    if isempty(ver)

        location = fileparts(mfilename("fullpath"));
        fileName = fullfile(location, "../../../.github/workflows/matlab.yml");

        if isfile(fileName)

            data = fileread(fileName);
            match = regexp(data, "VERSION: ""(?<version>\d+\.\d+\.\d+)""", "once", "names");

            if isempty(match)
                error("Could not determine version from ""matlab.yml"" file.");
            else
                ver = match.version;
            end
        else

            addOns = matlab.addons.installedAddons();
            locMAG = addOns.Name == "MAG Data Visualization";

            if any(locMAG) && (nnz(locMAG) == 1)
                ver = addOns{locMAG, "Version"};
            else
                error("Could not determine version from AddOns.");
            end
        end
    end

    v = ver;
end

function mustBeVersion(value)

    if ~matches(value, regexpPattern("\d+\.\d+\.\d+"))
        error("Version must be compliant with Semantic Versioning 2.0.0.");
    end
end
