function eventTable = generateEventTable(this, primaryOrSecondary, sensorEvents, data)

    arguments (Input)
        this (1, 1) mag.IMAPTestingAnalysis
        primaryOrSecondary (1, 1) string {mustBeMember(primaryOrSecondary, ["Primary", "Secondary"])}
        sensorEvents timetable
        data timetable
    end

    arguments (Output)
        eventTable eventtable
    end

    ranges = sortrows(data(:, "range"));

    % Select sensor.
    sensor = string(this.Results.getSensor(primaryOrSecondary));

    % Adapt existing event properties.
    sensorEvents.Reason = repmat("Command", height(sensorEvents), 1);

    if contains("Sensor", sensorEvents.Properties.VariableNames)

        sensorEvents = sensorEvents(ismissing([sensorEvents.Sensor]) | ([sensorEvents.Sensor] == sensor), :);
        sensorEvents = removevars(sensorEvents, "Sensor");
    end

    switch primaryOrSecondary
        case "Primary"
            sensorEvents = renamevars(sensorEvents, "PrimaryRate", "DataFrequency");
            sensorEvents = removevars(sensorEvents, "SecondaryRate");
        case "Secondary"
            sensorEvents = renamevars(sensorEvents, "SecondaryRate", "DataFrequency");
            sensorEvents = removevars(sensorEvents, "PrimaryRate");
    end

    % Improve timestamp estimates.
    sensorEvents = updateEventTimestamps(sensorEvents, data);

    % Add automatic transitions.
    locTimedCommand = ~ismissing(sensorEvents.Duration) & (sensorEvents.Duration ~= 0);

    idxTimedCommand = find(locTimedCommand);
    idxBaselineCommand = find(~locTimedCommand);

    for i = idxTimedCommand(:)'

        idx = idxBaselineCommand(idxBaselineCommand < i);

        if isempty(idx)
            error("Cannot determine initial event.");
        end

        autoEvent = sensorEvents(idx(end), :);
        autoEvent.Time = sensorEvents.Time(i) + seconds(sensorEvents.Duration(i));
        autoEvent.Reason = "Auto";

        sensorEvents = [sensorEvents; autoEvent]; %#ok<AGROW>
    end

    sensorEvents = sortrows(sensorEvents);

    % Extract first automatic range change in the session.
    if contains("Range", sensorEvents.Properties.VariableNames)

        firstRangeChange = sensorEvents(find(~ismissing([sensorEvents.Range]), 1), :).Time;

        if ~isempty(firstRangeChange)
            ranges = ranges(timerange(ranges.t(1), firstRangeChange - seconds(1)), "range");
        end
    end

    % Basic structure for events table.
    emptyTime = datetime.empty();
    emptyTime.TimeZone = "UTC";

    eventTable = struct2table(struct(Time = emptyTime, ...
        Mode = double.empty(0, 1), ...
        DataFrequency = double.empty(0, 1), ...
        PacketFrequency = double.empty(0, 1), ...
        Duration = double.empty(0, 1), ...
        Range = double.empty(0, 1), ...
        Label = string.empty(0, 1), ...
        Reason = string.empty(0, 1)));
    eventTable = table2timetable(eventTable, RowTimes = "Time");

    % Process range changes.
    % Range changes can be automatic, so add automatic transitions.
    if ~isempty(ranges)

        locRange = diff(ranges.range) ~= 0;
        rangeTable = vertcat(ranges(1, :), ranges(find(locRange) + 1, "range"));
        rangeTable = renamevars(rangeTable, "range", "Range");

        rangeTable.Label = compose("%s Range %d", primaryOrSecondary, [rangeTable.Range]);
        rangeTable.Reason = repmat("Auto", size(rangeTable, 1), 1);
        rangeTable.Properties.DimensionNames(1) = "Time";

        rangeTable = sortrows(rangeTable, "Time");

        if isempty(sensorEvents)

            eventTable = outerjoin(eventTable, rangeTable, MergeKeys = true, Keys = ["Time", intersect(eventTable.Properties.VariableNames, rangeTable.Properties.VariableNames)]);
            eventTable{:, "Mode"} = string(missing());
            eventTable{:, ["DataFrequency", "PacketFrequency"]} = double(missing());
        else
            eventTable = outerjoin(sensorEvents, rangeTable, MergeKeys = true, Keys = ["Time", intersect(sensorEvents.Properties.VariableNames, rangeTable.Properties.VariableNames)]);
        end
    else
        eventTable = outerjoin(eventTable, sensorEvents, MergeKeys = true, Keys = ["Time", intersect(eventTable.Properties.VariableNames, sensorEvents.Properties.VariableNames)]);
    end

    % Process variables.
    fillVariables = ["Mode", "DataFrequency", "PacketFrequency", "Range"];
    eventTable(:, fillVariables) = fillmissing(eventTable(:, fillVariables), "previous");

    eventTable.Mode = categorical(eventTable.Mode);
    eventTable.Reason = categorical(eventTable.Reason);

    eventTable{contains(eventTable.Label, "Config"), ["DataFrequency", "PacketFrequency", "Duration"]} = missing();
    eventTable{contains(eventTable.Label, "Ramp"), "Range"} = missing();

    % Convert to event table.
    eventTable = eventtable(eventTable, EventLabelsVariable = "Label");
end

function events = updateEventTimestamps(events, data)

    % Improve ramp mode estimate.
    idxRamp = find(contains([events.Label], "Ramp", IgnoreCase = true));
    idxRamp = vertcat(idxRamp, idxRamp + 1);

    rampEvents = events(idxRamp, :);

    if ~isempty(rampEvents)

        % Correct estimate based on science data.
        data = data(timerange(rampEvents.Time(1) - minutes(5), rampEvents.Time(end) + minutes(5), "closed"), :);

        matches = double.empty(2, 0);
        times = datetime.empty(2, 0);
        times.TimeZone = "UTC";

        for v = ["x", "y", "z"]

            dv = diff(data.(v));
            m = strfind(dv', mag.process.Ramp.Pattern);

            matches(:, end + 1) = [m(1); m(end)]; %#ok<AGROW>
            times(:, end + 1) = data.t(matches(:, end)); %#ok<AGROW>
        end

        if numel(unique(times)) > 2

            warning("Inconsistent ramp mode. Selecting earliest and latest timestamps as beginning and end.");

            idxStart = min(matches(1, :));
            idxEnd = max(matches(end, :));
        else

            idxStart = matches(1);
            idxEnd = matches(end);
        end

        events.Time(idxRamp(1)) = data.t(idxStart);
        events.Time(idxRamp(end)) = data.t(idxEnd + numel(mag.process.Ramp.Pattern) + 1);
    end
end
