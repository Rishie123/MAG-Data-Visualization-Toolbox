function loadHKData(this)
    %% Initialize

    if isempty(this.HKFileNames)
        return;
    end

    this.Results.HK = mag.HK.empty();

    %% Import and Process Data

    for hkp = 1:numel(this.HKPattern)

        [~, ~, extension] = fileparts(this.HKPattern(hkp));
        importStrategy = this.dispatchExtension(extension, "HK");

        hkData = mag.io.import( ...
            FileNames = this.HKFileNames{hkp}, ...
            Format = importStrategy, ...
            ProcessingSteps = this.HKProcessing);

        if ~isempty(hkData)
            this.Results.HK(end + 1) = hkData;
        end
    end

    %% Amend Timerange

    % Concentrate on recorded timerange.
    if ~isempty(this.Results.MetaData) && ~ismissing(this.Results.MetaData.Timestamp)

        for i = 1:numel(this.Results.HK)
            this.Results.HK(i).Data = this.Results.HK(i).Data(timerange(this.Results.MetaData.Timestamp, this.Results.HK(i).Time(end), "closed"), :);
        end
    end
end
