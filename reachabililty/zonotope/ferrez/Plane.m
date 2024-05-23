classdef Plane
    properties (GetAccess = public, SetAccess = private)
        n;
        p0;
    end
    methods (Access = public)
        function obj = Plane(n,p0)
            arguments
                n (3,1) double;
                p0 (3,1) double = zeros(3,1);
            end
            if norm(n) ~= 1
                n = normCols(n);
            end
            obj.n = n;
            obj.p0 = p0;
        end
        function Pn = rotate(obj,R)
            arguments
                obj;
                R (3,3) double;
            end
            Pn = Plane(R*obj.n,R*obj.p0);
        end
        function Pn = translate(obj,d)
            arguments
                obj;
                d (3,1) double;
            end
            Pn = Plane(obj.n,obj.p0 + d);
        end
        function Pn = transform(obj,R,d)
            arguments
                obj;
                R (3,3) double;
                d (3,1) double;
            end
            Pn = Plane(R*obj.n,R*obj.p0 + d);
        end
        function plot(obj,color,alpha)
            arguments
                obj;
                color (1,1) string = "#000000";
                alpha (1,1) double = 1;
            end
            axe = gca;
            p = obj.boundary();
            hold(axe,'on');
            fill3(axe,p(1,:),p(2,:),p(3,:),'k', ...
                "LineWidth",2, ...
                "EdgeColor",'k', ...
                "FaceAlpha",alpha, ...
                "FaceColor",color);
            % plotAxis(obj.n,sum(p,2)./size(p,2),color);
            hold(axe,'off');
        end
        function l = intersect(obj,P)
            arguments
                obj;
                P (1,1) Plane;
            end
            ha = obj.n.'*obj.p0;
            hb = P.n.'*P.p0;
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
            d = obj.n.'*(p - obj.p0);
        end
    end
    methods (Access = private)
        function p = boundary(obj)
            t = linspace(-pi,pi,100);
            R = frameFromNormal(obj.n);
            p = R.'*[cos(t);sin(t);0.*t];
            d = [0;0;obj.distanceFrom(p(:,1))];
            p = p - R.'*d;
        end
    end
end