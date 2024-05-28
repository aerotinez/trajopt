classdef Line
    properties (GetAccess = public, SetAccess = private)
        p0;
        d;
    end
    methods (Access = public)
        function obj = Line(p0,d)
            arguments
                p0 (3,1) double;
                d (3,1) double;
            end
            obj.p0 = p0;
            obj.d = d;
        end
        function p = point(obj,t)
            arguments
                obj;
                t (1,:) double;
            end
            p = obj.p0 + t.*obj.d;
        end
        function p = intersect(la,lb)
            arguments
                la (1,1) Line;
                lb (1,1) Line;
            end
            A = [-la.d,lb.d];
            if rank(A) < 2
                p = nan(3,1);
                return;
            end
            b = la.p0 - lb.p0;
            t = A\b;
            p = la.point(t(1));
        end
        function L = unique(L0)
            arguments
                L0 (1,:) Line;
            end
            d0 = cell2mat(arrayfun(@(l) l.d,L0,"uniform",0)).';
            [~,k] = unique(d0,'rows');
            L = L0(k);
        end
        function P = plot(obj,color)
            arguments
                obj;
                color (1,1) string = "#000000";
            end
            p = obj.point([-1,1]);
            axe = gca;
            hold(axe,'on');
            P = plot3(axe,p(1,:),p(2,:),p(3,:), ...
                "LineWidth",2, ...
                "Color",color);
            hold(axe,'off');
        end
    end
end