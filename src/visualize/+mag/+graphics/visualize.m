function varargout = visualize(varargin)
% VISUALIZE Plot data with specified styles and options.

    try
        [varargout(1:nargout)] = mag.graphics.factory.DefaultFactory().assemble(varargin{:});
    catch exception
        throwAsCaller(exception);
    end
end
