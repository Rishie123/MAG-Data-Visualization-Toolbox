classdef (Abstract) Factory
% FACTORY Interface for graphics generation factories.

    methods (Abstract)

        % VISUALIZE Plot data with specified styles and options.
        f = visualize(this, data, style, options)
    end
end
