classdef CDF < mag.io.Type
% CDF Import/Export MAG data to/from CDF.

    properties (Constant)
        Extension = ".cdf"
    end

    properties (Dependent)
        ScienceExportFormat
        HKExportFormat
    end

    methods

        function this = CDF(options)

            arguments
                options.?mag.io.CDF
            end

            args = namedargs2cell(options);

            if ~isempty(args)
                this.set(args{:});
            end
        end

        function scienceExportFormat = get.ScienceExportFormat(~)
            scienceExportFormat = mag.io.format.ScienceCDF();
        end

        function hkExportFormat = get.HKExportFormat(~)
            hkExportFormat = mag.io.format.HKCDF();
        end
    end

    methods

        function data = import(this, options)

            arguments
                this (1, 1) mag.io.CDF
                options.SkeletonLocation (1, 1) string {mustBeFolder}
                options.Level (1, 1) string = "1b"
                options.Version (1, 1) string = "V01"
            end


        end

        function export(this, data, options)

            arguments
                this (1, 1) mag.io.CDF
                data (1, 1) mag.io.format.CDF
                options.SkeletonLocation (1, 1) string {mustBeFolder} = fullfile("process/cdf")
                options.Level (1, 1) string = "1b"
                options.Version (1, 1) string = "V01"
            end

            % Load CDF information from skeleton.
            [~, sensor] = regexp(data.Sensor, "F(\w+)B", "once", "match", "tokens");
            skeletonCDF = fullfile(options.SkeletonLocation, sprintf("imap_mag_L%s_skeletontable_%s.cdf", options.Level, lower(sensor), options.Version));

            cdfInfo = spdfcdfinfo(skeletonCDF);

            %% Global Attributes

            globalAttributes = cdfInfo.GlobalAttributes;

            globalAttributes.Logical_source = sprintf('imap_L1b_mag%s', lower(data.MetaData.Mode{:}(1)));
            globalAttributes.Logical_file_id = char(this.ExportFileName);
            globalAttributes.Logical_source_description = sprintf('IMAP Magnetometer Level %s %s Mode Data in %s coordinates.', options.Level, data.MetaData.Mode, "S/C");
            globalAttributes.Generation_date = char(datetime("now", Format = "yyyy-MM-dd'T'HH:mm:SS"));
            globalAttributes.Software_version = char(metaData.ASW);

            globalAttributes.Distribution = 'Internal to Imperial College London';
            globalAttributes.Rules_of_use = 'Not for science use or publication';

            %% Variable Attributes

            variableAttributes = cdfInfo.VariableAttributes;

            variableAttributes.SCALEMAX{1, 2} = spdfdatenumtott2000(datenum(data.Time(1))); %#ok<*DATNM>
            variableAttributes.SCALEMIN{1, 2} = spdfdatenumtott2000(datenum(data.Time(end)));

            %% Values

            variableList = cell(2 * size(cdfInfo.Variables, 1), 1);
            variableList(1:2:end) = cdfInfo.Variables(:, 1);

            % Add time.
            variableList{2} = datenum(data.Time);

            % Add magnetic field.
            variableList{8} = data.DependentVariables{:, ["x", "y", "z"]};

            % Add labels.
            variableList{10} = spdfcdfread(skeletonCDF, 'Variable', variableAttributes.FIELDNAM{5, 1});
            variableList{12} = spdfcdfread(skeletonCDF, 'Variable', variableAttributes.FIELDNAM{6, 1});

            % Add sequence.
            variableList{14} = uint16(data.DependentVariables{:, "sequence"});

            % Add range.
            variableList{20} = uint8(data.DependentVariables{:, "range"});

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

            %% Data Types

            variableDataTypes = cell(2 * size(cdfInfo.Variables, 1), 1);
            variableDataTypes(1:2:end) = cdfInfo.Variables(:, 1);
            variableDataTypes(2:2:end) = cdfInfo.Variables(:, 4);

            %% Write CDF File

            spdfcdfwrite(char(this.ExportFileName), ...
                variableList, ...
                'GlobalAttributes', globalAttributes, ...
                'VariableAttributes', variableAttributes, ...
                'ConvertDatenumToTT2000', true, ...
                'WriteMode', 'overwrite', ...
                'Format', 'singlefile', ...
                'RecordBound', cdfInfo.Variables([1:2, 5:end], 1), ...
                'CDFCompress', 'gzip.6',...
                'Checksum', 'MD5', ...
                'VarDatatypes', variableDataTypes);
        end
    end
end
