classdef (Sealed) IMAPTestingAnalysis < matlab.mixin.Copyable & mag.mixin.SetGet & mag.mixin.SaveLoad
% IMAPTESTINGANALYSIS Automate analysis of an IMAP CPT or SFT folder.

    properties (Constant)
        Version = mag.version()
    end

    properties
        % LOCATION Location of data to load.
        Location (1, 1) string {mustBeFolder} = pwd()
        % EVENTPATTERN Pattern of event files.
        EventPattern (1, :) string = fullfile("*", "Event", "*.html")
        % METADATAPATTERN Pattern of meta data files.
        MetaDataPattern (1, :) string = [fullfile("*.msg"), fullfile("IMAP-MAG-TE-ICL-*.xlsx")]
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, :) string = fullfile("MAGScience-*-(*)-*.csv")
        % IALIRTPATTERN Pattern of I-ALiRT data files.
        IALiRTPattern (1, :) string = fullfile("MAGScience-IALiRT-*.csv")
        % HKPATTERN Pattern of housekeeping files.
        HKPattern (1, :) string = [fullfile("*", "Export", "idle_export_pwr.*.csv"), ...
            fullfile("*", "Export", "idle_export_stat.*.csv"), ...
            fullfile("*", "Export", "idle_export_conf.*.csv"), ...
            fullfile("*", "Export", "idle_export_proc.*.csv")]
        % PERFILEPROCESSING Steps needed to process single files of data.
        PerFileProcessing (1, :) mag.process.Step = [ ...
            mag.process.Missing(Variables = ["x", "y", "z"]), ...
            mag.process.Timestamp(), ...
            mag.process.DateTime(), ...
            mag.process.SignedInteger(), ...
            mag.process.Crop(NumberOfVectors = 1)]
        % WHOLEDATAPROCESSING Steps needed to process all of imported data.
        WholeDataProcessing (1, :) mag.process.Step = [ ...
            mag.process.Sort(), ...
            mag.process.Duplicates()]
        % SCIENCEPROCESSING Steps needed to process only strictly
        % science data.
        ScienceProcessing (1, :) mag.process.Step = [
            mag.process.Filter(OnRangeChange = [-seconds(0.5), seconds(0.5)]), ...
            mag.process.Range(), ...
            mag.process.Calibration()]
        % RAMPPROCESSING Steps needed to process only ramp mode data.
        RampProcessing (1, :) mag.process.Step = [ ...
            mag.process.Unwrap(Variables = ["x", "y", "z"]), ...
            mag.process.Ramp()]
        % HKPROCESSING Steps needed to process imported HK data.
        HKProcessing (1, :) mag.process.Step = [ ...
            mag.process.DateTime(), ...
            mag.process.Units()]
    end

    properties (Dependent)
        % EVENTFILENAMES Files containing event data.
        EventFileNames (1, :) string
        % METADATAFILENAMES Files containing meta data.
        MetaDataFileNames (1, :) string
        % SCIENCEFILENAMES Files containing science data.
        ScienceFileNames (1, :) string
        % IALIRTFILENAMES Files containing I-ALiRT data.
        IALiRTFileNames (1, :) string
        % HKFILENAMES Files containing HK data.
        HKFileNames (1, :) string
    end

    properties (SetAccess = private)
        % RESULTS Results collected during analysis.
        Results mag.Instrument {mustBeScalarOrEmpty}
    end

    properties (Access = private)
        % PRIMARYRAMP Primary ramp mode.
        PrimaryRamp mag.Science {mustBeScalarOrEmpty}
        % SECONDARYRAMP Secondary ramp mode.
        SecondaryRamp mag.Science {mustBeScalarOrEmpty}
    end

    properties (Hidden, Access = private)
        % EVENTFILES Information about files containing event data.
        EventFiles (:, 1) struct
        % METADATAFILES Information about files containing meta data.
        MetaDataFiles (:, 1) struct
        % SCIENCEFILES Information about files containing science data.
        ScienceFiles (:, 1) struct
        % IALIRTFILES Information about files containing I-ALiRT data.
        IALiRTFiles (:, 1) struct
        % HKFILES Information about files containing HK data.
        HKFiles cell
    end

    methods (Static)

        function analysis = start(options)
        % START Start automated analysis with options.

            arguments
                options.?mag.IMAPTestingAnalysis
            end

            args = namedargs2cell(options);
            analysis = mag.IMAPTestingAnalysis(args{:});

            analysis.detect();
            analysis.load();
        end
    end

    methods

        function this = IMAPTestingAnalysis(options)

            arguments
                options.?mag.IMAPTestingAnalysis
            end

            this.assignProperties(options);
        end

        function value = get.EventFileNames(this)
            value = string(fullfile({this.EventFiles.folder}, {this.EventFiles.name}));
        end

        function value = get.MetaDataFileNames(this)
            value = string(fullfile({this.MetaDataFiles.folder}, {this.MetaDataFiles.name}));
        end

        function value = get.ScienceFileNames(this)
            value = string(fullfile({this.ScienceFiles.folder}, {this.ScienceFiles.name}));
        end

        function value = get.IALiRTFileNames(this)
            value = string(fullfile({this.IALiRTFiles.folder}, {this.IALiRTFiles.name}));
        end

        function value = get.HKFileNames(this)

            for hkp = 1:numel(this.HKPattern)
                value{hkp} = string(fullfile({this.HKFiles{hkp}.folder}, {this.HKFiles{hkp}.name})); %#ok<AGROW>
            end
        end

        function detect(this)
        % DETECT Detect files based on filters.

            this.EventFiles = dir(fullfile(this.Location, this.EventPattern));

            metaDataDir = arrayfun(@dir, fullfile(this.Location, this.MetaDataPattern), UniformOutput = false);
            this.MetaDataFiles = vertcat(metaDataDir{:});

            this.ScienceFiles = dir(fullfile(this.Location, this.SciencePattern));

            this.IALiRTFiles = dir(fullfile(this.Location, this.IALiRTPattern));

            for hkp = 1:numel(this.HKPattern)
                this.HKFiles{hkp} = dir(fullfile(this.Location, this.HKPattern(hkp)));
            end
        end

        function load(this)
        % LOAD Load all data stored in selected location.

            this.Results = mag.Instrument();

            this.loadEventsData();

            [primaryMetaData, secondaryMetaData, hkMetaData] = this.loadMetaData();

            this.loadScienceData(primaryMetaData, secondaryMetaData);

            this.loadIALiRTData(primaryMetaData, secondaryMetaData);

            this.loadHKData(hkMetaData);
        end

        function modes = getAllModes(this)
        % GETALLMODES Get all modes as separate data.

            arguments (Input)
                this (1, 1) mag.IMAPTestingAnalysis
            end

            arguments (Output)
                modes (1, :) mag.Instrument
            end

            function [periods, modeEvents] = findModePeriods(data)

                events = data.Events;

                modeEvents = events(~ismissing(events.Duration), :);
                periods = repmat({timerange()}, 1, height(modeEvents));

                for e = 1:height(modeEvents)

                    if e == height(modeEvents)

                        idxTime = find(modeEvents.Time == modeEvents.Time(e), 1) + 1;

                        if idxTime > height(modeEvents)
                            endTime = data.Time(end);
                        else
                            endTime = modeEvents.Time(idxTime);
                        end
                    else
                        endTime = modeEvents.Time(e + 1);
                    end

                    periods{e} = timerange(modeEvents.Time(e), endTime, "closedleft");
                end
            end

            modes = mag.Instrument.empty();

            % Find duration for each mode.
            [primaryPeriods, primaryEvents] = findModePeriods(this.Results.Primary);
            [secondaryPeriods, secondaryEvents] = findModePeriods(this.Results.Secondary);

            % Split data into separate elements.
            if ~isempty(primaryPeriods) && ~isempty(secondaryPeriods)

                for p = 1:numel(primaryPeriods)

                    data = this.applyTimeRangeToInstrument(primaryPeriods{p}, secondaryPeriods{p});

                    if isempty(data)
                        continue;
                    end

                    data.Primary.MetaData.Mode = primaryEvents{p, "Mode"};
                    data.Primary.MetaData.DataFrequency = primaryEvents{p, "DataFrequency"};
                    data.Primary.MetaData.PacketFrequency = primaryEvents{p, "PacketFrequency"};

                    data.Secondary.MetaData.Mode = secondaryEvents{p, "Mode"};
                    data.Secondary.MetaData.DataFrequency = secondaryEvents{p, "DataFrequency"};
                    data.Secondary.MetaData.PacketFrequency = secondaryEvents{p, "PacketFrequency"};

                    modes(end + 1) = data; %#ok<AGROW>
                end
            end
        end

        function modeCycling = getModeCycling(this)
        % GETMODECYCLING Get mode cycling data.

            arguments (Input)
                this (1, 1) mag.IMAPTestingAnalysis
            end

            arguments (Output)
                modeCycling mag.Instrument {mustBeScalarOrEmpty}
            end

            function period = findModeCyclingPeriod(events)

                modeEvents = events((events.Reason == "Command") & ~ismissing(events.Duration), :);

                idxFirst = find(modeEvents.Mode == "Normal", 1);
                idxLast = find(diff(modeEvents.Mode == "Normal") == 0, 1);

                finalTime = events(find([events.Time] == modeEvents.Time(idxLast), 1) + 1, :).Time;
                modeEvents = modeEvents(idxFirst:idxLast, :);

                if isempty(modeEvents)
                    period = timerange(NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC"));
                else
                    period = timerange(modeEvents.Time(1), finalTime, "closedleft");
                end
            end

            modeCycling = this.applyTimeRangeToInstrument( ...
                findModeCyclingPeriod(this.Results.Primary.Events), ...
                findModeCyclingPeriod(this.Results.Secondary.Events));
        end

        function rangeCycling = getRangeCycling(this)
        % GETRANGECYCLING Get range cycling data.

            arguments (Input)
                this (1, 1) mag.IMAPTestingAnalysis
            end

            arguments (Output)
                rangeCycling mag.Instrument {mustBeScalarOrEmpty}
            end

            function period = findRangeCyclingPeriod(events)

                events = events(events.Reason == "Command", :);

                pattern = [3, 2, 1, 0];
                idxRange = strfind(events.Range', pattern);

                if isempty(idxRange)
                    period = timerange(NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC"));
                else
                    period = timerange(events.Time(idxRange), events.Time(idxRange + 4) - milliseconds(1), "closed");
                end
            end

            rangeCycling = this.applyTimeRangeToInstrument( ...
                findRangeCyclingPeriod(this.Results.Primary.Events), ...
                findRangeCyclingPeriod(this.Results.Secondary.Events));
        end

        function rampMode = getRampMode(this)
        % GETRAMPMODE Get ramp mode data.

            arguments (Input)
                this (1, 1) mag.IMAPTestingAnalysis
            end

            arguments (Output)
                rampMode mag.Instrument {mustBeScalarOrEmpty}
            end

            rampMode = this.Results.copy();

            rampMode.Primary = this.PrimaryRamp;
            rampMode.Secondary = this.SecondaryRamp;

            if rampMode.HasScience
                rampMode.cropToMatch();
            else
                rampMode = mag.Instrument.empty();
            end
        end

        function finalNormal = getFinalNormalMode(this)
        % GETFINALNORMALMODE Get normal mode at the end of analysis.

            arguments (Input)
                this (1, 1) mag.IMAPTestingAnalysis
            end

            arguments (Output)
                finalNormal mag.Instrument {mustBeScalarOrEmpty}
            end

            function period = findFinalNormalMode(events, endTime)

                if any(events{end-2:end, "Mode"} == "Normal")

                    events = events((events.Mode == "Normal") & (events.DataFrequency == 2), :);
                    period = timerange(events.Time(end), endTime, "closed");
                else
                    period = timerange(NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC"));
                end
            end

            finalNormal = this.applyTimeRangeToInstrument( ...
                findFinalNormalMode(this.Results.Primary.Events, this.Results.Primary.Time(end)), ...
                findFinalNormalMode(this.Results.Secondary.Events, this.Results.Secondary.Time(end)));
        end

        function periods = splitByTimeGap(this, gap)
        % SPLITBYTIMEGAP Split data based on gap in the data of specified
        % magnitude.

            arguments (Input)
                this (1, 1) mag.IMAPTestingAnalysis
                gap (1, 1) duration
            end

            arguments (Output)
                periods (1, :) mag.Instrument
            end

            tPrimary = this.Results.Primary.Time;
            dtPrimary = diff(tPrimary);
            tSplitPrimary = [tPrimary(1); tPrimary(dtPrimary > gap)];

            tSecondary = this.Results.Secondary.Time;
            dtSecondary = diff(tSecondary);
            tSplitSecondary = [tSecondary(1); tSecondary(dtSecondary > gap)];

            if ~isequal(numel(tSplitPrimary), numel(tSplitSecondary))
                error("Unequal time splits in primary (%d) and secondary(%d) data. Try a different time gap.", numel(tSplitPrimary), numel(tSplitSecondary));
            end

            for i = 1:(numel(tSplitPrimary) - 1)

                periods(i) = this.applyTimeRangeToInstrument(timerange(tSplitPrimary(i), tSplitPrimary(i + 1), "open"), ...
                    timerange(tSplitSecondary(i), tSplitSecondary(i + 1), "open")); %#ok<AGROW>
            end
        end

        % EXPORT Export data to specified format.
        export(this, exportStrategy, options)
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@matlab.mixin.Copyable(this);
            copiedThis.Results = copy(this.Results);
        end
    end

    methods (Access = private)

        % LOADEVENTSDATA Load events.
        loadEventsData(this)

        % LOADMETADATA Load meta data.
        [primaryMetaData, secondaryMetaData, hkMetaData] = loadMetaData(this)

        % LOADSCIENCEDATA Load science data.
        loadScienceData(this, primaryMetaData, secondaryMetaData)

        % LOADHKDATA Load HK data.
        loadHKData(this, hkMetaData)

        % GENERATEEVENTTABLE Create an event table for a sensor, based on
        % detected events and science data.
        eventTable = generateEventTable(this, primaryOrSecondary, sensorEvents, data)

        function result = applyTimeRangeToInstrument(this, primaryPeriod, secondaryPeriod)
        % APPLYTIMERANGETOTABLE Apply timerange to timetable and its
        % events.

            arguments (Input)
                this
                primaryPeriod (1, 1) timerange
                secondaryPeriod (1, 1) timerange
            end

            arguments (Output)
                result mag.Instrument {mustBeScalarOrEmpty}
            end

            result = this.Results.copy();

            if isempty(result)
                return;
            end

            result.crop(primaryPeriod, secondaryPeriod);

            if isempty(result.Primary.Data) || isempty(result.Secondary.Data)
                result = mag.Instrument.empty();
            end
        end
    end

    methods (Hidden, Sealed, Static)

        function loadedObject = loadobj(object)
        % LOADOBJ Override default loading from MAT file.

            if isa(object, "mag.IMAPTestingAnalysis")

                loadedObject = object;

                if strlength(object.OriginalVersion) ~= 0
                    return;
                end

                % If no original version is available, make sure the HK
                % data is dispatched to the correct classes.
                results = loadedObject.Results;

                for hk = 1:numel(results.HK)
                    results.HK(hk) = mag.hk.dispatchHKType(results.HK(hk).Data, results.HK(hk).MetaData);
                end
            elseif isa(object, "struct")

                % Recreate object based on version.
                if isequal(object.OriginalVersion, 1.0)

                    % Convert object to version 2.0 and recursively
                    % dispatch it.
                    loadedObject = struct();
                    loadedObject.Version = 2.0;

                    for p = ["Location", "EventPattern", "MetaDataPattern", "SciencePattern", "HKPattern", ...
                            "PerFileProcessing", "WholeDataProcessing", "ScienceProcessing", "RampProcessing", "HKProcessing", ...
                            "Events", "MetaData", "HK", "EventFiles", "MetaDataFiles", "ScienceFiles", "HKFiles"]

                        if isfield(object, p)
                            loadedObject.(p) = object.(p);
                        end
                    end

                    mapping = dictionary(Outboard = "Primary", Inboard = "Secondary", OutRamp = "PrimaryRamp", InRamp = "SecondaryRamp");

                    for k = mapping.keys()'
                        loadedObject.(mapping(k)) = object.(k);
                    end

                    loadedObject = mag.IMAPTestingAnalysis.loadobj(loadedObject);
                elseif isequal(object.OriginalVersion, 2.0)

                    % Convert object directly to version 2.5.
                    loadedObject = mag.IMAPTestingAnalysis();
                    loadedObject.Results = mag.Instrument();

                    for p = ["Location", "EventPattern", "MetaDataPattern", "SciencePattern", "HKPattern", ...
                            "PerFileProcessing", "WholeDataProcessing", "ScienceProcessing", "RampProcessing", "HKProcessing", ...
                            "EventFiles", "MetaDataFiles", "ScienceFiles", "HKFiles", ...
                            "PrimaryRamp", "SecondaryRamp"]

                        loadedObject.(p) = object.(p);
                    end

                    for p = ["Events", "MetaData", "Primary", "Secondary", "HK"]
                        loadedObject.Results.(p) = object.(p);
                    end
                end
            else
                error("Cannot retrieve ""mag.IMAPTestingAnalysis"" from ""%s"".", class(object));
            end
        end
    end

    methods (Static, Access = private)

        function importExportStrategy = dispatchExtension(extension, options)
        % DISPATCHEXTENSION Dispatch extension to correct I/O strategy.

            arguments (Input)
                extension
                options.?mag.io.Type
            end

            arguments (Output)
                importExportStrategy (1, 1) mag.io.Type
            end

            args = namedargs2cell(options);

            switch extension
                case cellstr(mag.io.CSV.Extension)
                    importExportStrategy = mag.io.CSV(args{:});
                otherwise
                    error("Unsupported extension ""%s"" for science data import.", extension);
            end
        end
    end
end
