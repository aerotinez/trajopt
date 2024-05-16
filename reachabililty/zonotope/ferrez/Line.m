classdef Line
    properties (GetAccess = public, SetAccess = private)
        d;
        r0;
    end
    methods (Access = public)
        function obj = Line(d,r0)
            arguments
                
                d (3,1) double;
                r0 (3,1) double;
            end
            obj.d = d;
            obj.r0 = r0;
        end
        function r = point(obj,t)
            arguments
                obj (1,1) Line;
                t (1,1) double;
            end
            r = obj.r0 + t.*obj.d;
        end
        function l = plot(obj,t0,tf)
            arguments
                obj (1,1) Line;
                t0 (1,1) double = -1;
                tf (1,1) double = 1;
            end
            p0 = obj.r0 + t0.*obj.d;
            pf = obj.r0 + tf.*obj.d;
            P = [p0,pf];
            axe = gca;
            hold(axe,"on");
            plot3(axe,P(1,:),P(2,:),P(3,:),'k',"LineWidth",2);
            hold(axe,"off");
            if sum(P(3,:)) > eps
                view(axe,3);
            end
        end
    end
end