classdef SID15 < mag.meta.log.Type
% SID15 Load meta data from SID15 HK files.

    properties (Constant)
        Extensions = ".csv"
    end

    properties
        % PROCESSINGSTEPS Steps needed to process imported data.
        ProcessingSteps (1, :) mag.process.Step = [ ...
            mag.process.DateTime(TimeVariable = "SHCOARSE")]
    end

    methods

        function this = SID15(options)

            arguments
                options.?mag.meta.log.SID15
            end

            this.assignProperties(options);
        end
    end

    methods (Hidden)

        function [instrumentMetaData, primaryMetaData, secondaryMetaData] = load(this, instrumentMetaData, primaryMetaData, secondaryMetaData)

            arguments (Input)
                this
                instrumentMetaData (1, 1) mag.meta.Instrument
                primaryMetaData (1, :) mag.meta.Science
                secondaryMetaData (1, :) mag.meta.Science
            end

            arguments (Output)
                instrumentMetaData (1, 1) mag.meta.Instrument
                primaryMetaData (1, :) mag.meta.Science
                secondaryMetaData (1, :) mag.meta.Science
            end

            % Load data.
            dataStore = tabularTextDatastore(this.FileName, TextType = "string", FileExtensions = this.Extensions, SelectedVariableNames = ["SHCOARSE", "ISV_FOB_ACTTRIES", "ISV_FIB_ACTTRIES"]);
            rawData = dataStore.readall(UseParallel = ~isempty(gcp("nocreate")));

            rawData = sortrows(rawData, "SHCOARSE");

            % Process data.
            for ps = this.ProcessingSteps
                rawData = ps.apply(rawData, mag.meta.Data.empty());
            end

            % Extract attempts.
            fobAttempts = median(rawData{rawData.ISV_FOB_ACTTRIES ~= 0, "ISV_FOB_ACTTRIES"});
            fibAttempts = median(rawData{rawData.ISV_FIB_ACTTRIES ~= 0, "ISV_FIB_ACTTRIES"});

            instrumentMetaData.Attemps = [fobAttempts, fibAttempts];

            instrumentMetaData.Timestamp = rawData{1, "SHCOARSE"};
            instrumentMetaData.Timestamp.TimeZone = mag.process.DateTime.TimeZone;
            instrumentMetaData.Timestamp.Format = mag.process.DateTime.Format;
        end
    end
end
