classdef zonotope2d < zonotope
    methods (Access = public)
        function obj = zonotope2d(genertors,center)
            arguments
                genertors (2,:) double;
                center (2,1) double = zeros(2,1);
            end
            obj@zonotope(genertors,center);
        end
        function plot(obj)
            axe = gca;
            P = obj.generate();
            k = convhull(P(1,:),P(2,:));
            H = P(:,k).';
            hold(axe,"on");
            fill(H(:,1),H(:,2),[0,0.4470,0.7410], ...
                "FaceAlpha",0, ...
                "EdgeColor","b");
            % scatter(axe,P(1,:),P(2,:),"filled",'k');
            hold(axe,"off");
        end 
    end
end