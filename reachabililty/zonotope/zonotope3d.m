classdef zonotope3d < zonotope
    methods (Access = public)
        function obj = zonotope3d(genertors,center)
            arguments
                genertors (3,:) double;
                center (3,1) double = zeros(3,1);
            end
            obj@zonotope(genertors,center);
        end
        function plot(obj,axe)
            arguments
                obj zonotope3d;
                axe = [];
            end
            if isempty(axe)
                fig = figure();
                axe = axes(fig);
            end
            view(axe,3);
            P = obj.generate();
            k = convhull(P(1,:),P(2,:),P(3,:),"Simplify",true);
            H = unique(P(:,k).',"rows");
            DT = delaunayTriangulation(H);
            [Tfb,Xfb] = freeBoundary(DT);
            TR = triangulation(Tfb,Xfb);
            hold(axe,"on");
            trisurf(TR,"EdgeColor","none","FaceColor",[0,0.4470,0.7410]);
            lighting(axe,"flat");
            hold(axe,"off");
            axis(axe,"equal");  
            box(axe,"on");
            camproj(axe,"perspective");
            light(axe,"Style","local","Position",[0,0,max(H(:,3)) + 1000]);
        end 
    end
end