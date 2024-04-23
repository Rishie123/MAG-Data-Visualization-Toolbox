classdef ScienceCDF < mag.io.out.CDF
% SCIENCECDF Format science data for CDF export.

    methods

        function this = ScienceCDF(options)

            arguments
                options.?mag.io.out.ScienceCDF
            end

            this.assignProperties(options)
        end

        function fileName = getExportFileName(this, data)

            fileName = compose("imap_mag_%s_%s-mag%s_%s_%s.cdf", ...
                lower(this.Level), ...
                lower(string(data.MetaData.Mode)), ...
                lower(extract(string(data.MetaData.Sensor), regexpPattern("[O|I]"))), ...
                datestr(data.MetaData.Timestamp, "yyyymmdd"), ...
                lower(this.Version)); %#ok<DATST>
        end
    end

    methods (Access = protected)

        function fileName = getSkeletonFileName(this)
            fileName = fullfile(this.SkeletonLocation, sprintf("imap_mag_%s_skeletontable_%s.cdf", lower(this.Level), lower(this.Version)));
        end

        function globalAttributes = getGlobalAttributes(this, cdfInfo, data)

            globalAttributes = cdfInfo.GlobalAttributes;

            globalAttributes.Logical_source = sprintf('imap_L1b_mag%s', lower(data.MetaData.Mode(1)));
            globalAttributes.Logical_file_id = cdfInfo.Filename;
            globalAttributes.Logical_source_description = sprintf('IMAP Magnetometer Level %s %s Mode Data in %s coordinates.', this.Level, data.MetaData.Mode, "S/C");
            globalAttributes.Generation_date = char(datetime("now", Format = "yyyy-MM-dd'T'HH:mm:SS"));
            globalAttributes.Software_version = char.empty();

            globalAttributes.Distribution = 'Internal to Imperial College London';
            globalAttributes.Rules_of_use = 'Not for science use or publication';
        end

        function variableAttributes = getVariableAttributes(~, cdfInfo, data)

            variableAttributes = cdfInfo.VariableAttributes;

            variableAttributes.SCALEMAX{1, 2} = spdfdatenumtott2000(datenum(data.Time(1))); %#ok<DATNM>
            variableAttributes.SCALEMIN{1, 2} = spdfdatenumtott2000(datenum(data.Time(end))); %#ok<DATNM>
        end

        function variableDataTypes = getVariableDataType(~, cdfInfo)

            variableDataTypes = cell(2 * size(cdfInfo.Variables, 1), 1);
            variableDataTypes(1:2:end) = cdfInfo.Variables(:, 1);
            variableDataTypes(2:2:end) = cdfInfo.Variables(:, 4);
        end

        function recordBound = getRecordBound(~, cdfInfo)
            recordBound = cdfInfo.Variables([1:2, 5:end], 1);
        end

        function variableList = getVariableList(this, cdfInfo, data)

            variableList = cell(2 * size(cdfInfo.Variables, 1), 1);
            variableList(1:2:end) = cdfInfo.Variables(:, 1);

            % Add time.
            variableList{2} = datenum(data.Time); %#ok<DATNM>

            % Add magnetic field.
            variableList{8} = data.XYZ;

            % Add labels.
            fileName = this.getSkeletonFileName();
            variableAttributes = this.getVariableAttributes(cdfInfo, data);

            variableList{10} = spdfcdfread(fileName, 'Variable', variableAttributes.FIELDNAM{5, 1});
            variableList{12} = spdfcdfread(fileName, 'Variable', variableAttributes.FIELDNAM{6, 1});

            % Add sequence.
            variableList{14} = uint16(data.Sequence);

            % Add range.
            variableList{20} = uint8(data.Range);

            % Add remaining variables as NaNs or zeros.
            numRows = numel(variableList{2});

            variableList{4} = NaN(numRows, 1, "double");
            variableList{6} = zeros(numRows, 1, "uint8");
            variableList{16} = NaN(numRows, 1, "double");
            variableList{18} = NaN(numRows, 1, "single");
            variableList{22} = zeros(numRows, 1, "uint8");
            variableList{24} = zeros(numRows, 1, "uint8");
            variableList{26} = zeros(numRows, 1, "uint8");
            variableList{28} = zeros(numRows, 1, "uint16");
        end
    end
end
