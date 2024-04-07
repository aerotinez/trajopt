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
            k = convhull(P(1,:),P(2,:),P(3,:),"Simplify",true);
            H = unique(P(:,k).',"rows");
            hold(axe,"on"); 
            plot(alphaShape(H), ...
                "FaceColor","#4DBEEE", ...
                "EdgeColor","none", ...
                "FaceLighting","flat", ...
                "EdgeLighting","flat");
            % scatter3(axe,P(1,:),P(2,:),P(3,:),"filled",'k');
            hold(axe,"off");
            axis(axe,"equal");  
            box(axe,"on");
            camproj(axe,"perspective");
            light(axe,"Style","local","Position",[0,0,max(H(:,3)) + 50]);
        end 
    end
end