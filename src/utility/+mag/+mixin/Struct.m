classdef (Abstract, HandleCompatible) Struct
% STRUCT Interface adding support for cropping of data.

    methods (Hidden, Sealed)

        function structThis = struct(this)
        % STRUCT Convert class to struct containing only public properties.

            arguments (Input)
                this (1, 1) mag.mixin.Struct
            end

            arguments (Output)
                structThis (1, 1) struct
            end

            metaClasses = metaclass(this);

            for mc = metaClasses

                metaProperties = mc.PropertyList;
                metaProperties = metaProperties(~[metaProperties.Constant] & ({metaProperties.GetAccess} == "public") & ({metaProperties.SetAccess} == "public"));

                for mp = metaProperties'

                    if isa(this.(mp.Name), "mag.mixin.Struct")
                        structThis.(mp.Name) = struct(this.(mp.Name));
                    else
                        structThis.(mp.Name) = this.(mp.Name);
                    end
                end

                metaClasses = [metaClasses, mc.SuperclassList']; %#ok<AGROW>
            end
        end
    end
end
