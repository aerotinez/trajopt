classdef HyperPlane
    properties (GetAccess = public, SetAccess = private)
        g;
    end
    methods (Access = public)
        function obj = HyperPlane(g)
            arguments
                g (:,1) double;
            end
            obj.g = g;
        end
    end
end