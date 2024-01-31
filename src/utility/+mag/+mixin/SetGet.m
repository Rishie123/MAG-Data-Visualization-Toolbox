classdef (Abstract) SetGet < matlab.mixin.SetGetExactNames
% SETGET Interface adding support for handling of constructor arguments.

    methods (Sealed)

        function set(this, varargin)
        % SET Customize setting property values. The method also accepts a
        % struct of properties.

            if (nargin() == 2) && isstruct(varargin{1})
                args = namedargs2cell(varargin{1});
            else
                args = varargin;
            end

            if ~isempty(args)
                set@matlab.mixin.SetGetExactNames(this, args{:});
            end
        end
    end

    methods (Sealed, Access = protected)

        function assignProperties(this, options)
            this.set(options);
        end
    end
end
