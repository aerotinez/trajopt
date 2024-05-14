classdef Layer < handle
    properties (Access = public)
        Generators;
        Vertices;
    end
    methods (Access = public)
        function obj = Layer(generators,vertices)
            arguments
                generators double;
                vertices double = zeros(size(generators,1),1);
            end
            obj.Generators = generators;
            obj.Vertices = vertices;
        end
        function plot(obj)
            axe = gca;
            v = obj.Vertices;
            hold(axe,"on");
            switch size(v,1)
                case 2
                    scatter(axe,v(1,:),v(2,:),"filled");
                case 3
                    scatter3(axe,v(1,:),v(2,:),v(3,:),"filled");
            end
            hold(axe,"off");
        end
    end 
end