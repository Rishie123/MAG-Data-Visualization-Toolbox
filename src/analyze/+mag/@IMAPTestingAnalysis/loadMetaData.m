function [primaryMetaData, secondaryMetaData, hkMetaData] = loadMetaData(this)
    %%  Initialize

    metaData = mag.meta.Instrument();
    primaryMetaData = mag.meta.Science(Sensor = "FOB");
    secondaryMetaData = mag.meta.Science(Sensor = "FIB");
    hkMetaData = mag.meta.HK.empty();

    %% Instrument and Science Meta Data

    for mdf = this.MetaDataFileNames

        [~, ~, extension] = fileparts(mdf);

        switch extension
            case cellstr(mag.meta.log.GSEOS.Extensions)
                loader = mag.meta.log.GSEOS(FileName = mdf);
            case cellstr(mag.meta.log.Excel.Extensions)
                loader = mag.meta.log.Excel(FileName = mdf);
            case cellstr(mag.meta.log.SID15.Extensions)
                loader = mag.meta.log.SID15(FileName = mdf);
        end

        [metaData, primaryMetaData, secondaryMetaData] = loader.load(metaData, primaryMetaData, secondaryMetaData);
    end

    %% HK Meta Data

    for hkp = 1:numel(this.HKPattern)

        if isempty(this.HKFileNames{hkp})
            continue;
        end

        rawData = regexp(this.HKFileNames{hkp}(1), mag.meta.HK.MetaDataFilePattern, "names");

        timestamp = datetime(rawData.date + rawData.time, InputFormat = "yyyyMMddHHmmss", TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format);
        hkMetaData(end + 1) = mag.meta.HK(Type = rawData.type, Timestamp = timestamp); %#ok<AGROW>
    end

    %% Assign Value

    this.Results.MetaData = metaData;
end
