function loadHKData(this, hkMetaData)

    this.Results.HK = mag.HK.empty();

    for hkp = 1:numel(this.HKPattern)

        % Import data.
        [~, ~, extension] = fileparts(this.HKPattern(hkp));
        rawHK = this.dispatchExtension(extension, ImportFileNames = this.HKFileNames{hkp}).import();

        if ~isempty(rawHK)

            % Preprocess variables.
            rawHK = sortrows(vertcat(rawHK{:}), "SHCOARSE");
            rawHK = renamevars(rawHK, "SHCOARSE", "t");

            % Apply processing steps.
            for ps = this.HKProcessing
                rawHK = ps.apply(rawHK, hkMetaData(hkp));
            end

            % Assign value.
            this.Results.HK(end + 1) = mag.hk.dispatchHKType(table2timetable(rawHK, RowTimes = "t"), hkMetaData(hkp));
        end
    end

    % Concentrate on recorded timerange.
    if ~isempty(this.Results.MetaData) && ~ismissing(this.Results.MetaData.Timestamp)

        for i = 1:numel(this.Results.HK)
            this.Results.HK(i).Data = this.Results.HK(i).Data(timerange(this.Results.MetaData.Timestamp, this.Results.HK(i).Time(end), "closed"), :);
        end
    end
end
