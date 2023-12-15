classdef Export < mag.process.Step
% EXPORT Export data with desired format during processing.
%
% Export sample data in between or at the end of the processing pipeline.
% Can be used to evaluate how data evolves during processing.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % EXPORTSTRATEGY Strategy providing format of exported data.
        ExportStrategy (1, 1) mag.io.Type = mag.io.MAT()
        % EXPORTFORMAT Export format for data.
        ExportFormat (1, 1) mag.io.format.Data = mag.io.format.ScienceMAT()
        % EXPORTNAMEFORMAT Function returning name of export file, based on
        % meta data.
        ExportNameFormat (1, 1) function_handle = @(metaData) "export"
    end

    methods

        function this = Export(options)

            arguments
                options.?mag.process.Export
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Export Data";
        end

        function value = get.Description(this)
            value = "Export data to """ + this.ExportStrategy.Extension + """ format.";
        end

        function value = get.DetailedDescription(this)

            value = this.Description + " Exported data can be used to " + ...
                "analyze partial results during through the processing pipeline.";
        end

        function data = apply(this, data, metaData)

            exportedData = this.ExportFormat.formatForExport(data, metaData);

            this.ExportStrategy.ExportFileName = this.ExportNameFormat(metaData);
            this.ExportStrategy.export(exportedData);
        end
    end
end
