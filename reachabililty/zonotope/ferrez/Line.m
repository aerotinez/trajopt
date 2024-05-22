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
        function P = plot(obj,color)
            arguments
                obj;
                color (1,1) string = "#000000";
            end
            % p = normCols(obj.point(2*[-1,1]));
            pf = obj.p0 + obj.d;
            p = [obj.p0,pf];
            axe = gca;
            hold(axe,'on');
            P = plot3(axe,p(1,:),p(2,:),p(3,:), ...
                "LineWidth",2, ...
                "Color",color);
            hold(axe,'off');
        end
    end
end