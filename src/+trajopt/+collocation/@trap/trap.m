classdef trap < trajopt.collocation.Program
    methods (Access = protected)
        setMesh(obj);
        cost(obj);
        defect(obj);
    end
end