classdef Plane
    properties (GetAccess = public, SetAccess = public)
        n;
        p;
    end
    methods (Access = public)
        function obj = Plane(n)
            arguments
                n (3,1) double;
            end
            if norm(n) ~= 1
                n = normCols(n);
            end
            obj.n = n;
            obj.p = obj.boundary();
        end
        function plot(obj,color,alpha)
            arguments
                obj;
                color (1,1) string = "#000000";
                alpha (1,1) double = 1;
            end
            axe = gca;
            hold(axe,'on');
            fill3(axe,obj.p(1,:),obj.p(2,:),obj.p(3,:),'k', ...
                "LineWidth",2, ...
                "EdgeColor",'k', ...
                "FaceAlpha",alpha, ...
                "FaceColor",color);
            % plotAxis(obj.n,zeros(3,1),color);
            hold(axe,'off');
        end
        function l = intersect(obj,P)
            arguments
                obj;
                P (1,1) Plane;
            end
            ha = obj.n.'*obj.p(:,1);
            hb = P.n.'*P.p(:,1);
            n0 = obj.n.'*P.n;
            ca = (ha - hb*n0)/(1 - n0^2);
            cb = (hb - ha*n0)/(1 - n0^2);
            l = Line(ca*obj.n + cb*P.n,normCols(cross(obj.n,P.n)));
        end
        function d = distanceFrom(obj,p)
            arguments
                obj;
                p (3,:) double;
            end
            d = obj.n.'*(p - obj.p(:,1));
        end
    end
    methods (Access = private)
        function p = boundary(obj)
            t = linspace(-pi,pi,100);
            p = frameFromNormal(obj.n).'*[cos(t);sin(t);0.*t];
        end
    end
end