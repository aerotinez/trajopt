classdef ZonoHull < handle
    properties (GetAccess = public, SetAccess = private)
        Layers Layer;
    end
    methods (Access = public)
        function obj = ZonoHull(generators)
            arguments
                generators double;
            end
            obj.Layers = Layer(generators);
            obj.propagateLayers(); 
        end
        function plot(obj)
            fig = figure();
            axe = axes(fig);
            for i = 1:numel(obj.Layers)
                obj.Layers(i).plot();
            end
            axis(axe,"equal");
            box(axe,"on");
            view(axe,3);
            camproj(axe,"perspective");
        end
    end
    methods (Access = private)
        function addLayer(obj)
            layer = obj.Layers(end);
            G = obj.setGenerators(layer);
            v = obj.setVertices(layer);
            obj.Layers = [obj.Layers,Layer(G,v)];
        end
        function G = setGenerators(~,layer)
            G0 = layer.Generators;
            n = size(G0,1);
            m = size(G0,2);
            N = size(G0,3);
            G = zeros(n,m - 1,N*m);
            for j = 1:N
                for k = 1:m
                    G(:,:,(j - 1)*m + k) = G0(:,k ~= 1:m,j);
                end
            end
        end
        function v = setVertices(~,layer)
            G = layer.Generators;
            p = reshape(layer.Vertices,size(G,1),1,[]) + G;
            v = reshape(p, size(G,1), []);
        end 
        function propagateLayers(obj)
            G = obj.Layers(end).Generators;
            m = size(G,2);
            while m > 0
                obj.addLayer();
                kd = obj.findDuplicates();
                obj.prune(kd);
                % kh = obj.findHull();
                % obj.prune(kh);
                G = obj.Layers(end).Generators;
                m = size(G,2);
            end
        end
        function idx = findDuplicates(obj)
            v0 = obj.Layers(end - 1).Vertices;
            vf = obj.Layers(end).Vertices;
            idx = true(1,size(vf,2));
            for k = 1:size(vf,2)
                if max(sum(vf(:,k) == v0,1)) == size(v0,1)
                    idx(k) = false;
                end
            end
        end
        function idx = findHull(obj)
            v = obj.Layers(end).Vertices.';
            if size(unique(v,"rows"),1) < 3
                idx = 1:size(v,1);
                return;
            end
            k = convhull(v);
            idx = unique(k(:));
        end 
        function prune(obj,idx)
            obj.Layers(end).Vertices = obj.Layers(end).Vertices(:,idx);
            obj.Layers(end).Generators = obj.Layers(end).Generators(:,:,idx);
        end
    end
end