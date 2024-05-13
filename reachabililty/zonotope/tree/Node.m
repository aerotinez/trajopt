classdef Node < handle
    properties (GetAccess = public, SetAccess = private)
        Vertex;
        Generators;
        Children;
    end
    methods (Access = public)
        function obj = Node(vertex,generators)
            arguments
                vertex (1,:) double;
                generators double;
            end
            obj.Vertex = vertex;
            obj.Generators = generators;
            obj.Children = Node.empty(1,0);
        end
        function addChild(obj,node)
            arguments
                obj (1,1) Node;
                node (1,1) Node;
            end
            obj.Children(end + 1) = node;
        end
    end
end