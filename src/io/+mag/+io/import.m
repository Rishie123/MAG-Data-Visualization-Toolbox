function data = import(options)
% IMPORT Import data from specified files with specified format.

    arguments (Input)
        options.FileNames (1, :) string {mustBeFile}
        options.Format (1, 1) mag.io.in.Format
        options.ProcessingSteps (1, :) mag.process.Step = mag.process.Step.empty()
    end

    arguments (Output)
        data (1, :) mag.TimeSeries
    end

    data = mag.TimeSeries.empty();

    for i = 1:numel(options.FileNames)
        data = [data, options.Format.loadAndConvert(options.FileNames(i))]; %#ok<AGROW>
    end

    for ps = options.ProcessingSteps

        for d = data
            d.Data = ps.apply(d.Data, d.MetaData);
        end
    end

    data = options.Format.combineByType(data);
end