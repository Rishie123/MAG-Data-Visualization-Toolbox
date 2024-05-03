classdef (Abstract) View < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% VIEW Abstract base class for view of MAG data.

    properties (Constant, Access = protected)
        % FLABEL Frequency label.
        FLabel (1, 1) string = "frequency [Hz]"
        % PLABEL Power label.
        PLabel (1, 1) string = "power [dB]"
        % PSDLABEL PSD label.
        PSDLabel (1, 1) string = "PSD [nT Hz^{-0.5}]"
        % TLABEL Temperature label.
        TLabel (1, 1) string = "T [" + char(176) + "C]"
    end

    properties (SetAccess = protected)
        % RESULTS Data to visualize.
        Results (1, 1) mag.Instrument
        % FIGURES Figures generated by view.
        Figures (1, :) matlab.ui.Figure
    end

    methods (Sealed)

        function figures = visualizeAll(this)
        % VISUALIZEALL Visualize all views in array and return figures.

            if isempty(this)
                figures = matlab.ui.Figure.empty();
            else

                arrayfun(@(v) v.visualize(), this);
                figures = [this.Figures];
            end
        end
    end

    methods (Abstract)

        % VISUALIZE Visualize data.
        visualize(this)
    end

    methods (Access = protected)

        function [primarySensor, secondarySensor] = getSensorNames(this)
        % GETSENSORNAMES Get names of primary and secondary sensors.

            primarySensor = string(this.Results.Science.getName("Primary"));
            secondarySensor = string(this.Results.Science.getName("Secondary"));
        end

        function hkType = getHKType(this, type)
        % GETHKTYPE Get specific type of HK. Default is power HK.

            arguments
                this
                type (1, 1) string {mustBeMember(type, ["PROCSTAT", "PW", "SID15", "STATUS"])} = "PW"
            end

            hkType = this.Results.HK.getHKType(type);
        end
    end

    methods (Static, Access = protected)

        function date = date2str(date, format)
        % DATE2STR Convert datetime to string.

            arguments
                date (1, 1) datetime
                format (1, 1) string = "dd-MMM-yyyy HHmmss"
            end

            date.Format = format;
        end
    end
end
