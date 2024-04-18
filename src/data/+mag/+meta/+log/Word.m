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

        function [instrumentMetaData, primarySetup, secondarySetup] = load(this, instrumentMetaData, primarySetup, secondarySetup)

            arguments
                this (1, 1) mag.meta.log.Word
                instrumentMetaData (1, 1) mag.meta.Instrument
                primarySetup (1, 1) mag.meta.Setup
                secondarySetup (1, 1) mag.meta.Setup
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

            % Determine whether model is FM or EM.
            if contains(this.FileName, "IMAP-MAG-TE-ICL-071")

                model = "FM";
                primaryFEE = "FEE3";
                secondaryFEE = "FEE4";
            elseif contains(this.FileName, "IMAP-OPS-TE-ICL-001")

                model = "EM";
                primaryFEE = "FEE1";
                secondaryFEE = "FEE2";
            end

            % Assign instrument meta data.
            instrumentMetaData.Model = model;
            instrumentMetaData.BSW = extractAfter(rawData.BSW, optionalPattern(lettersPattern()));
            instrumentMetaData.ASW = extractAfter(rawData.ASW, optionalPattern(lettersPattern()));
            instrumentMetaData.GSE = extractAfter(rawData.GSE, optionalPattern(lettersPattern()));
            instrumentMetaData.Operator = rawData.Operator;
            instrumentMetaData.Description = rawData.Name;
            instrumentMetaData.Timestamp = datetime(rawData.Date, TimeZone = "UTC", Format = mag.time.Constant.Format) + duration(rawData.Time, InputFormat = "hh:mm");

            % Enhance primary and secondary meta data.
            primarySetup.Model = rawData.FOBModel;
            primarySetup.FEE = primaryFEE;
            primarySetup.Harness = rawData.FOBHarness;
            primarySetup.Can = rawData.FOBCan;

            secondarySetup.Model = rawData.FIBModel;
            secondarySetup.FEE = secondaryFEE;
            secondarySetup.Harness = rawData.FIBHarness;
            secondarySetup.Can = rawData.FIBCan;
        end
    end
end
