classdef (Sealed) AutomatedAnalysis < matlab.mixin.Copyable & mag.mixin.SetGet
% AUTOMATEDANALYSIS Automate analysis of a CPT or SFT folder.

    properties (Constant, Hidden)
        % VERSION Version number.
        Version (1, 1) double = 3.0
    end

    properties
        % LOCATION Location of data to load.
        Location (1, 1) string {mustBeFolder} = pwd()
        % EVENTPATTERN Pattern of event files.
        EventPattern (1, :) string = fullfile("*", "Event", "*.html")
        % METADATAPATTERN Pattern of meta data files.
        MetaDataPattern (1, :) string = [fullfile("*.msg"), fullfile("IMAP-MAG-TE-ICL-*.xlsx")]
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, :) string = fullfile("MAGScience*.csv")
        % HKPATTERN Pattern of housekeeping files.
        HKPattern (1, :) string = [fullfile("*", "Export", "idle_export_pwr.*.csv"), ...
            fullfile("*", "Export", "idle_export_stat.*.csv"), ...
            fullfile("*", "Export", "idle_export_conf.*.csv")]
        % PERFILEPROCESSING Steps needed to process single files of data.
        PerFileProcessing (1, :) mag.process.Step = [ ...
            mag.process.Missing(Variables = ["x", "y", "z"]), ...
            mag.process.Timestamp(), ...
            mag.process.DateTime(), ...
            mag.process.SignedInteger()]
        % WHOLEDATAPROCESSING Steps needed to process all of imported data.
        WholeDataProcessing (1, :) mag.process.Step = [ ...
            mag.process.Sort(), ...
            mag.process.Duplicates()]
        % SCIENCEPROCESSING Steps needed to process only strictly
        % science data.
        ScienceProcessing (1, :) mag.process.Step = [
            mag.process.Filter(OnRangeChange = [-seconds(1), seconds(1)], OnModeChange = [-seconds(1), seconds(1)]), ...
            mag.process.Range(), ...
            mag.process.Calibration(), ...
            mag.process.Magnitude()]
        % RAMPPROCESSING Steps needed to process only ramp mode data.
        RampProcessing (1, :) mag.process.Step = [ ...
            mag.process.Unwrap(Variables = ["x", "y", "z"]), ...
            mag.process.Derivative(Variables = ["x", "y", "z"]), ...
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
        % HKFILES Information about files containing HK data.
        HKFiles cell
    end

    methods (Static)

        function analysis = start(options)
        % START Start automated analysis with options.

            arguments
                options.?mag.AutomatedAnalysis
            end

            args = namedargs2cell(options);
            analysis = mag.AutomatedAnalysis(args{:});

            analysis.detect();
            analysis.load();
        end
    end

    methods

        function this = AutomatedAnalysis(options)

            arguments
                options.?mag.AutomatedAnalysis
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

            this.loadHKData(hkMetaData);
        end

        function modes = getAllModes(this)
        % GETALLMODES Get all modes as separate data.

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

            arguments (Output)
                rampMode mag.Instrument {mustBeScalarOrEmpty}
            end

            rampMode = this.Results.copy();

            rampMode.Primary = this.PrimaryRamp;
            rampMode.Secondary = this.SecondaryRamp;

            if rampMode.HasScience
                rampMode.cropDataBasedOnScience();
            else
                rampMode = mag.Instrument.empty();
            end
        end

        function finalNormal = getFinalNormalMode(this)
        % GETFINALNORMALMODE Get normal mode at the end of analysis.

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

            result.Primary.Data = result.Primary.Data(primaryPeriod, :);
            result.Primary.Data.Properties.Events = result.Primary.Data.Properties.Events(primaryPeriod, :);

            result.Secondary.Data = result.Secondary.Data(secondaryPeriod, :);
            result.Secondary.Data.Properties.Events = result.Secondary.Data.Properties.Events(secondaryPeriod, :);

            if isempty(result.Primary.Data) || isempty(result.Secondary.Data)
                result = mag.Instrument.empty();
            else
                result.cropDataBasedOnScience();
            end
        end
    end

    methods (Hidden, Sealed, Static)

        function loadedObject = loadobj(object)
        % LOADOBJ Override default loading from MAT file.

            if isa(object, "mag.AutomatedAnalysis")
                loadedObject = object;
            elseif isa(object, "struct")

                % Recreate object based on version.
                if isfield(object, "Outboard")

                    % Convert object to version 2.0 and recursively
                    % dispatch it.
                    loadedObject = struct();
                    loadedObject.Version = 2.0;

                    for p = ["Location", "EventPattern", "MetaDataPattern", "SciencePattern", "HKPattern", ...
                            "PerFileProcessing", "WholeDataProcessing", "ScienceProcessing", "RampProcessing", "HKProcessing", ...
                            "Events", "MetaData", "HK", "EventFiles", "MetaDataFiles", "ScienceFiles", "HKFiles"]

                        loadedObject.(p) = object.(p);
                    end

                    mapping = dictionary(Outboard = "Primary", Inboard = "Secondary", OutRamp = "PrimaryRamp", InRamp = "SecondaryRamp");

                    for k = mapping.keys()'
                        loadedObject.(mapping(k)) = object.(k);
                    end

                    loadedObject = mag.AutomatedAnalysis.loadobj(loadedObject);
                elseif isfield(object, "PrimaryRamp")

                    % Convert object directly to version 3.0.
                    loadedObject = mag.AutomatedAnalysis();
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
                error("Cannot retrieve ""mag.AutomatedAnalysis"" from ""%s"".", class(object));
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
