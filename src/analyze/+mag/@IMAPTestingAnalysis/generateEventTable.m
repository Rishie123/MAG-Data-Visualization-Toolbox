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
    if contains("Sensor", sensorEvents.Properties.VariableNames)

        sensorEvents = sensorEvents(ismissing([sensorEvents.Sensor]) | ([sensorEvents.Sensor] == sensor), :);
        sensorEvents = removevars(sensorEvents, "Sensor");
    end

    sensorEvents = removeUninterestingVariables(sensorEvents, primaryOrSecondary);

    % Improve ramp mode timestamp estimates.
    sensorEvents = updateRampModeTimestamps(sensorEvents, data);

    % Improve estimates of mode changes.
    sensorEvents = findModeChanges(data, sensorEvents);

    % Basic structure for events table.
    emptyTime = datetime.empty();
    emptyTime.TimeZone = "UTC";

    eventTable = struct2table(struct(Time = emptyTime, ...
        Mode = string.empty(0, 1), ...
        DataFrequency = double.empty(0, 1), ...
        PacketFrequency = double.empty(0, 1), ...
        Duration = double.empty(0, 1), ...
        Range = double.empty(0, 1), ...
        Label = string.empty(0, 1), ...
        Reason = string.empty(0, 1)));
    eventTable = table2timetable(eventTable, RowTimes = "Time");

    % Process range changes.
    % Range changes can be automatic, so add automatic transitions. If they
    % are commanded, correct the times at which they occur.
    if ~isempty(ranges)

        [rangeTable, sensorEvents] = findRangeChanges(ranges, sensorEvents, primaryOrSecondary);

        if isempty(sensorEvents)

            eventTable = joinEventTables(eventTable, rangeTable);
            eventTable{:, "Mode"} = string(missing());
            eventTable{:, ["DataFrequency", "PacketFrequency"]} = double(missing());
        else
            eventTable = joinEventTables(sensorEvents, rangeTable);
        end

    % Just use sensor events.
    else
        eventTable = joinEventTables(eventTable, sensorEvents);
    end

    % Add sensor shutdown.
    shutDownTable = array2timetable(repmat(missing(), [1, numel(eventTable.Properties.VariableNames)]), RowTimes = max(data.t) + eps(), VariableNames = eventTable.Properties.VariableNames);
    shutDownTable.Label = primaryOrSecondary + " Shutdown";
    shutDownTable.Reason = "Command";

    eventTable = [eventTable; shutDownTable];

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

function sensorEvents = removeUninterestingVariables(sensorEvents, primaryOrSecondary)

    % Remove uninteresting sensor events and rename selected sensor ones.
    switch primaryOrSecondary
        case "Primary"

            sensorEvents = renamevars(sensorEvents, ["PrimaryNormalRate", "PrimaryBurstRate"], ["DataNormalFrequency", "DataBurstFrequency"]);
            sensorEvents = removevars(sensorEvents, regexpPattern("Secondary\w*"));
        case "Secondary"

            sensorEvents = renamevars(sensorEvents, ["SecondaryNormalRate", "SecondaryBurstRate"], ["DataNormalFrequency", "DataBurstFrequency"]);
            sensorEvents = removevars(sensorEvents, regexpPattern("Primary\w*"));
    end

    % Only select active mode data and packet frequency.
    sensorEvents.DataFrequency = NaN([height(sensorEvents), 1]);
    sensorEvents.PacketFrequency = NaN([height(sensorEvents), 1]);

    filter = rowfilter(sensorEvents);

    sensorEvents{filter.Mode == "Normal", "DataFrequency"} = sensorEvents{filter.Mode == "Normal", "DataNormalFrequency"};
    sensorEvents{filter.Mode == "Burst", "DataFrequency"} = sensorEvents{filter.Mode == "Burst", "DataBurstFrequency"};

    sensorEvents{filter.Mode == "Normal", "PacketFrequency"} = sensorEvents{filter.Mode == "Normal", "PacketNormalFrequency"};
    sensorEvents{filter.Mode == "Burst", "PacketFrequency"} = sensorEvents{filter.Mode == "Burst", "PacketBurstFrequency"};

    % Rearrange variables.
    sensorEvents = removevars(sensorEvents, regexpPattern("(Data|Packet)\w+Frequency"));
    sensorEvents = movevars(sensorEvents, ["DataFrequency", "PacketFrequency"], After = "Mode");
end

function events = updateRampModeTimestamps(events, data)

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

function events = findModeChanges(data, events)

    searchWindow = seconds(5);
    data = sortrows(data);

    % Update timestamps for mode changes.
    idxMode = find(diff(events.DataFrequency) ~= 0) + 1;

    for i = idxMode'

        % Find window around event and compute actual timestamp difference.
        t = events.Time(i);
        eventWindow = data(withtol(t, searchWindow), :);

        dt = seconds(diff(eventWindow.t));
        [~, idxChange] = max(diff(dt), [], ComparisonMethod = "abs");

        if ~isempty(eventWindow)
            events.Time(i) = eventWindow.t(idxChange + 1);
        end
    end
end

function [rangeTable, events] = findRangeChanges(ranges, events, primaryOrSecondary)

    % Find range changes.
    locRange = diff(ranges.range) ~= 0;

    rangeTable = vertcat(ranges(1, :), ranges(find(locRange) + 1, "range"));
    rangeTable = renamevars(rangeTable, "range", "Range");
    rangeTable.Properties.DimensionNames(1) = "Time";

    % Update timestamps for commanded range changes.
    idxDelete = [];

    for i = 1:height(rangeTable)

        e = events(withtol(rangeTable.Time(i), minutes(1)), "Range");

        if any(e.Range == rangeTable.Range(i))

            events.Time(events.Time == e.Time) = rangeTable.Time(i);
            idxDelete(end + 1) = i; %#ok<AGROW>
        end
    end

    rangeTable(idxDelete, :) = [];
    events{~contains(events.Label, "Range"), "Range"} = missing();

    % Complete automatic range changes.
    rangeTable.Label = compose("%s Range %d", primaryOrSecondary, [rangeTable.Range]);
    rangeTable.Reason = repmat("Auto", size(rangeTable, 1), 1);

    rangeTable = sortrows(rangeTable, "Time");
end

function eventTable = joinEventTables(table1, table2)
    eventTable = outerjoin(table1, table2, MergeKeys = true, Keys = ["Time", intersect(table1.Properties.VariableNames, table2.Properties.VariableNames)]);
end
