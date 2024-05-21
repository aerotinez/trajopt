classdef StereographicProjection
    properties (GetAccess = public, SetAccess = private)
        p;
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
            [p0,pf] = lineSphereIntersection(intersect(Pa,Pb));
            f = @(pa,pb)sqrt((pa - pb).'*(pa - pb));
            f0 = @(p)f(p0,p);
            ff = @(p)f(pf,p);
            P0 = cell2mat(cellfun(f0,num2cell(pb,1),"uniform",0));
            Pf = cell2mat(cellfun(ff,num2cell(pb,1),"uniform",0));
            [~,k0] = min(P0);
            [~,kf] = min(Pf);
            pb = circshift(pb,size(pb,2) - max([k0,kf]),2);
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
            d = normCols(pf - p0);
            l = Line(p0,d);
        end
    end
end