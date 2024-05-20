classdef StereographicProjection
    properties (GetAccess = public, SetAccess = private)
        p;
        p0;
        pf; 
    end
    methods (Access = public)
        function obj = StereographicProjection(Pa,Pb)
            arguments
                Pa (1,1) Plane;
                Pb (1,1) Plane;
            end
            n = Pa.n;
            d = Pa.distanceFrom(Pb.p);
            pb = Pb.p(:,d > 0);
            R = frameFromNormal(n);
            obj.p = R.'*(pb - (n.'*pb).*n);
            if sum(obj.p(3,:)) > 1E-10
                error("The projection is not well defined");
            end
            obj.p = obj.p(1:2,:); 
        end
        function plot(obj,color)
            arguments
                obj;
                color (1,1) string = "#000000";
            end
            axe = gca;
            hold(axe,'on');
            scatter(axe,obj.p(1,:),obj.p(2,:),10,"filled", ...
                "MarkerFaceColor",color, ...
                "LineWidth",2); 
            hold(axe,'off');
        end
    end
end