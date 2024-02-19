function loadEventsData(this)
    %% Load Event Files
    
    rawEvents = string.empty();

    for ef = this.EventFileNames

        contents = extractFileText(ef);
        rawEvents = join([rawEvents, contents], newline);
    end

    rawEvents = regexp(rawEvents, "(?<timestamp>\d+/\d+/\d+ \d+:\d+:\d+):(?<category>\w+) :: (?<command>\w+)(?: \[\d+, \d+, \d+\] )?\((?<details>.*?)\)", "names", "dotexceptnewline", "lineanchors");
    eventTimeFormat = "yyyy/MM/dd HH:mm:ss";

    if isempty(rawEvents)
        return;
    end

    %% Convert Events

    events = mag.event.Event.empty();

    % Identify config mode events.
    locConfig = [rawEvents.command] == "MAG_M_CONF";

    for ce = rawEvents(locConfig)

        eventDetails = regexp(ce.details, mag.event.Event.CommonFormat + mag.event.ModeChange.SpecificFormat, "once", "names");
        events(end + 1) = mag.event.ModeChange( ...
            CommandTimestamp = datetime(ce.timestamp, Format = eventTimeFormat, TimeZone = "UTC"), ...
            Type = eventDetails.type, ...
            SubType = eventDetails.subtype, ...
            Mode = "Config", ...
            PrimaryRate = missing(), ...
            SecondaryRate = missing(), ...
            PacketFrequency = missing(), ...
            Duration = missing()); %#ok<AGROW>
    end

    % Identify normal mode events.
    locNormal = [rawEvents.command] == "MAG_M_NORM";

    for ne = rawEvents(locNormal)

        eventDetails = regexp(ne.details, mag.event.Event.CommonFormat + ", NORMPRI_RATE=HZ_(?<primary>\d+), NORMSEC_RATE=HZ_(?<secondary>\d+), NORM_PKTSECS=SECS_(?<packets>\d+), BRSTPRI_RATE=(?:HZ_\d+|\w+), BRSTSEC_RATE=(?:HZ_\d+|\w+), BRST_PKTSECS=(?:SECS_\d+|\w+)", "once", "names");
        events(end + 1) = mag.event.ModeChange( ...
            CommandTimestamp = datetime(ne.timestamp, Format = eventTimeFormat, TimeZone = "UTC"), ...
            Type = eventDetails.type, ...
            SubType = eventDetails.subtype, ...
            Mode = "Normal", ...
            PrimaryRate = eventDetails.primary, ...
            SecondaryRate = eventDetails.secondary, ...
            PacketFrequency = eventDetails.packets); %#ok<AGROW>
    end

    % Identify burst mode events.
    locBurst = [rawEvents.command] == "MAG_M_BURST";

    for be = rawEvents(locBurst)

        eventDetails = regexp(be.details, mag.event.Event.CommonFormat + ", NORMPRI_RATE=(?:HZ_\d+|\w+), NORMSEC_RATE=(?:HZ_\d+|\w+), NORM_PKTSECS=(?:SECS_\d+|\w+), BRSTPRI_RATE=HZ_(?<primary>\d+), BRSTSEC_RATE=HZ_(?<secondary>\d+), BRST_PKTSECS=SECS_(?<packets>\d+), BRST_DURATION=(?<duration>\d+)", "once", "names");
        events(end + 1) = mag.event.ModeChange( ...
            CommandTimestamp = datetime(be.timestamp, Format = eventTimeFormat, TimeZone = "UTC"), ...
            Type = eventDetails.type, ...
            SubType = eventDetails.subtype, ...
            Mode = "Burst", ...
            PrimaryRate = eventDetails.primary, ...
            SecondaryRate = eventDetails.secondary, ...
            PacketFrequency = eventDetails.packets, ...
            Duration = eventDetails.duration); %#ok<AGROW>
    end

    % Identify range changes.
    locRange = matches([rawEvents.command], regexpPattern("MAG_FEE_F(O|I)BRNG"));

    for re = rawEvents(locRange)

        eventDetails = regexp(re.details, mag.event.Event.CommonFormat + mag.event.RangeChange.SpecificFormat, "once", "names");
        events(end + 1) = mag.event.RangeChange( ...
            CommandTimestamp = datetime(re.timestamp, Format = eventTimeFormat, TimeZone = "UTC"), ...
            Type = eventDetails.type, ...
            SubType = eventDetails.subtype, ...
            Range = eventDetails.range, ...
            Sensor = regexp(re.command, "F(O|I)B", "once", "match")); %#ok<AGROW>
    end

    % Identify ramp changes.
    locRamp = matches([rawEvents.command], regexpPattern("MAG_FEE_F(O|I)BRAMP_EN"));

    for re = rawEvents(locRamp)

        eventDetails = regexp(re.details, mag.event.Event.CommonFormat + mag.event.RampMode.SpecificFormat, "once", "names");
        events(end + 1) = mag.event.RampMode( ...
            CommandTimestamp = datetime(re.timestamp, Format = eventTimeFormat, TimeZone = "UTC"), ...
            Type = eventDetails.type, ...
            SubType = eventDetails.subtype, ...
            Sensor = regexp(re.command, "F(O|I)B", "once", "match")); %#ok<AGROW>
    end

    %% Add Response Times

    % Identify acknowledge response events.
    locAccepted = matches([rawEvents.command], regexpPattern("MAG_TCA_SUCC"));
    acknowledgeEvents = rawEvents(locAccepted);

    if ~isempty(acknowledgeEvents)

        responsePattern = getResponsePattern(acknowledgeEvents(1).details);

        acknowledgedId = regexp([acknowledgeEvents.details], responsePattern, "names", "all");
        acknowledgedId = [acknowledgedId{:}];

        for i = string(fieldnames(acknowledgedId))'
            [acknowledgeEvents.(i)] = acknowledgedId.(i);
        end

        for i = 1:numel(acknowledgeEvents)

            acknowledgeEvents(i).timestamp = datetime(acknowledgeEvents(i).timestamp, Format = eventTimeFormat, TimeZone = "UTC");
            acknowledgeEvents(i).coarse = datetime(mag.time.Constant.Epoch + str2double(acknowledgeEvents(i).coarse), ConvertFrom = "posixtime", TimeZone = mag.time.Constant.TimeZone);
        end
    end

    % Identify complete response events.
    locCompleted = matches([rawEvents.command], regexpPattern("MAG_TCC_SUCC"));
    completedEvents = rawEvents(locCompleted);

    if ~isempty(completedEvents)

        responsePattern = getResponsePattern(completedEvents(1).details);

        completedId = regexp([completedEvents.details], responsePattern, "names", "all");
        completedId = [completedId{:}];

        for i = string(fieldnames(completedId))'
            [completedEvents.(i)] = completedId.(i);
        end

        for i = 1:numel(completedEvents)

            completedEvents(i).timestamp = datetime(completedEvents(i).timestamp, Format = eventTimeFormat, TimeZone = "UTC");
            completedEvents(i).coarse = datetime(mag.time.Constant.Epoch + str2double(completedEvents(i).coarse), ConvertFrom = "posixtime", TimeZone = mag.time.Constant.TimeZone);
        end
    end

    % Assign acknowlegdement and completion times.
    for e = events

        correction = duration.empty();

        ae = acknowledgeEvents([acknowledgeEvents.timestamp] >= e.CommandTimestamp);
        ce = completedEvents([completedEvents.timestamp] >= e.CommandTimestamp);

        % Remove responses to subsequent commands of the same type.
        similarSubsequentEvents = events(([events.Type] == e.Type) & ([events.SubType] == e.SubType) & ([events.CommandTimestamp] > e.CommandTimestamp));

        if ~isempty(similarSubsequentEvents)

            ae = ae([ae.timestamp] < similarSubsequentEvents(1).CommandTimestamp);
            ce = ce([ce.timestamp] < similarSubsequentEvents(1).CommandTimestamp);
        end

        % Find acknoledgement time.
        if isfield(ae, "type") && isfield(ae, "subtype")

            ae = ae((str2double([ae.type]) == e.Type) & (str2double([ae.subtype]) == e.SubType));

            if isempty(ae)
                e.AcknowledgeTimestamp = e.CommandTimestamp;
            else

                e.AcknowledgeTimestamp = ae(1).coarse;
                correction(end + 1) = ae(1).coarse - ae(1).timestamp; %#ok<AGROW>
            end
        end

        % Find completion time.
        if isfield(ce, "type") && isfield(ce, "subtype")

            ce = ce((str2double([ce.type]) == e.Type) & (str2double([ce.subtype]) == e.SubType));

            if isempty(ce)
                e.CompleteTimestamp = e.AcknowledgeTimestamp;
            else

                e.CompleteTimestamp = ce(1).coarse;
                correction(end + 1) = ce(1).coarse - ce(1).timestamp; %#ok<AGROW>
            end
        end

        if ~isempty(correction)
            e.CommandTimestamp = e.CommandTimestamp + mean(correction);
        end
    end

    %% Assign Value

    this.Results.Events = sort(events);
end

function responsePattern = getResponsePattern(response)

    persistent responsePattern14 responsePattern17

    if isempty(responsePattern14) || isempty(responsePattern17)

        responsePattern14 = "All data =\[\d+, \d+, \d+, \d+, \d+, \d+, \d+, (?<coarse>\d+), \d+, \d+, \d+, \d+, \d+, (?:\d+/\d+/\d+ \d+:\d+:\d+:\w+ :: )?\d+, \d+\]";
        responsePattern17 = "All data =\[\d+, \d+, \d+, \d+, \d+, \d+, \d+, (?<coarse>\d+), \d+, \d+, \d+, \d+, \d+, (?:\d+/\d+/\d+ \d+:\d+:\d+:\w+ :: )?\d+, \d+, \d+, (?<type>\d+), (?<subtype>\d+)\]";
    end

    commaCount = count(response, ",");

    switch commaCount
        case 14
            responsePattern = responsePattern14;
        case 17
            responsePattern = responsePattern17;
        otherwise
            error("Unrecognized number of commas in response message.");
    end
end
