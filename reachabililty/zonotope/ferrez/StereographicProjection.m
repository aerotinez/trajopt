classdef StereographicProjection
    properties (GetAccess = public, SetAccess = private)
        P0;
        P;
        p;
    end
    methods (Access = public)
        function obj = StereographicProjection(P0,P)
            arguments
                P0 (1,1) Plane;
                P (1,1) Plane;
            end
            obj.P0 = P0;
            obj.P = P;
            pt = obj.partitionPlane();
            ps = obj.shiftEndPoints(pt);
            obj.p = obj.project(ps); 
        end
        function plot(obj,color)
            arguments
                obj;
                color (1,1) string = "#000000";
            end
            axe = gca;
            hold(axe,'on');
            plot(axe,obj.p(1,:),obj.p(2,:), ...
                "Color",color, ...
                "LineWidth",2);
            scatter(axe,obj.p(1,1),obj.p(2,1),20,"filled", ...
                "MarkerFaceColor",'r');
            scatter(axe,obj.p(1,end),obj.p(2,end),20,"filled", ...
                "MarkerFaceColor",'g');
            hold(axe,'off');
        end
        function l = toLine(obj)
            p0 = [obj.p(:,1);0];
            pf = [obj.p(:,end);0];
            d = pf - p0;
            l = Line(p0,d);
        end
    end
    methods (Access = private)
        function p = partitionPlane(obj)
            d = obj.P0.distanceFrom(obj.P.p);
            p = obj.P.p(:,d > 0);
        end 
        function pout = shiftEndPoints(~,pin)
            [pmax,k] = max(vecnorm(diff(pin,1,2),2,1));
            if pmax < 1E-01
                pout = pin;
                return;
            end
            pout = circshift(pin,-k,2); 
        end
        function p = project(obj,p0)
            R = frameFromNormal(obj.P0.n);
            pt = R*(p0 - (obj.P0.n.'*p0).*obj.P0.n);
            if sum(pt(3,:)) > 1E-10
                error("The projection is not well defined");
            end
            p = pt(1:2,:);
        end
    end
end