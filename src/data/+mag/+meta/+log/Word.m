classdef Word < mag.meta.log.Type
% WORD Load meta data from Word files.

    properties (Constant)
        Extensions = ".docx"
    end

    methods

        function this = Word(options)

            arguments
                options.?mag.meta.log.Word
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

            % Read meta data file.
            % If Word document does not contain table, ignore it.
            importOptions = wordDocumentImportOptions(TableSelector = "//w:tbl[contains(.,'MAG Operator')]");
            rawData = readtable(this.FileName, importOptions);

            if isempty(rawData)
                return;
            end

            rawData = rows2vars(rawData, VariableNamesSource = 1, VariableNamingRule = "preserve");
            rawData = renamevars(rawData, 2:15, ["Operator", "Controller", "Date", "Time", "Name", "BSW", "ASW", "GSE", "FOBModel", "FOBHarness", "FOBCan", "FIBModel", "FIBHarness", "FIBCan"]);

            % Assign instrument meta data.
            instrumentMetaData.Model = "FM";
            instrumentMetaData.BSW = extractAfter(rawData.BSW, optionalPattern(lettersPattern()));
            instrumentMetaData.ASW = extractAfter(rawData.ASW, optionalPattern(lettersPattern()));
            instrumentMetaData.GSE = extractAfter(rawData.GSE, optionalPattern(lettersPattern()));
            instrumentMetaData.Operator = rawData.Operator;
            instrumentMetaData.Description = rawData.Name;
            instrumentMetaData.Timestamp = datetime(rawData.Date, TimeZone = "UTC", Format = mag.time.Constant.Format) + duration(rawData.Time, InputFormat = "hh:mm");

            % Enhance primary and secondary meta data.
            [primaryMetaData.Model] = deal(rawData.FOBModel);
            [primaryMetaData.FEE] = deal("FEE3");
            [primaryMetaData.Harness] = deal(rawData.FOBHarness);
            [primaryMetaData.Can] = deal(rawData.FOBCan);

            [secondaryMetaData.Model] = deal(rawData.FIBModel);
            [secondaryMetaData.FEE] = deal("FEE4");
            [secondaryMetaData.Harness] = deal(rawData.FIBHarness);
            [secondaryMetaData.Can] = deal(rawData.FIBCan);
        end
    end
end
