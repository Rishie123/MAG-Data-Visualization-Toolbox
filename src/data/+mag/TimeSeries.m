classdef (Abstract) TimeSeries < mag.Data
% TIMESERIES Abstract base class for MAG time series.

    properties
        % DATA Timetable containing data.
        Data timetable
    end

    properties (Dependent)
        % TIME Timestamp of data.
        Time (:, 1) datetime
        % DT Time derivative.
        dT (:, 1) duration
        IndependentVariable
        DependentVariables
    end

    methods

        function time = get.Time(this)
            time = this.Data.(this.Data.Properties.DimensionNames{1});
        end

        function dt = get.dT(this)
            dt = [diff(this.Time); duration(missing())];
        end

        function independentVariable = get.IndependentVariable(this)
            independentVariable = this.Time;
        end

        function dependentVariables = get.DependentVariables(this)
            dependentVariables = timetable2table(this.Data, ConvertRowTimes = false);
        end
    end

    methods (Abstract)

        % CROP Crop data based on selected filter.
        crop(this, timeFilter)

        % RESAMPLE Resample data to the specified frequency.
        resample(this, targetFrequency)

        % DOWNSAMPLE Downsample data to the specified frequency.
        downsample(this, targetFrequency)
    end
end
