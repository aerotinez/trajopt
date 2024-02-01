classdef nlpmesh < handle
    properties (GetAccess = public, SetAccess = private)
        Mesh;
        NumPoints;
    end
    methods (Access = public)
        function obj = nlpmesh(mesh) 
            obj.set(mesh); 
        end
        function set(obj,new_mesh)
            arguments
                obj (1,1) nlpmesh;
                new_mesh (1,:) double;
            end
            obj.Mesh = new_mesh;
            obj.NumPoints = numel(new_mesh);
            obj.validate();
        end
    end
    methods (Access = private)
        function validate(obj)
            msg = "Mesh must be a sorted array from 0 to 1.";
            if ~issorted(obj.Mesh)
                error(msg)
            end
            if obj.Mesh(1) ~= 0
                error(msg)
            end
            if obj.Mesh(end) ~= 1
                error(msg)
            end
        end
    end
end