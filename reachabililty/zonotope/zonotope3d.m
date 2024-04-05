classdef zonotope3d < zonotope
    methods (Access = public)
        function obj = zonotope3d(genertors,center)
            arguments
                genertors (3,:) double;
                center (3,1) double = zeros(3,1);
            end
            obj@zonotope(genertors,center);
        end
        function plot(obj)
            axe = gca;
            view(axe,3);
            P = obj.generate();
            k = convhull(P(1,:),P(2,:),P(3,:));
            H = unique(P(:,k).',"rows");
            hold(axe,"on"); 
            plot(alphaShape(H),"FaceColor","r","FaceAlpha",0.3);
            scatter3(axe,P(1,:),P(2,:),P(3,:),"filled",'k');
            hold(axe,"off");
        end 
    end
end