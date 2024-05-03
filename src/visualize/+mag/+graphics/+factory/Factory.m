classdef (Abstract) Factory
% FACTORY Interface for graphics generation factories.

    methods (Abstract)

        % ASSEMBLE Plot data with specified styles and options.
        f = assemble(this, data, style, options)
    end
end
