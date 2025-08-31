classdef Trapezoidal < directcollocation.Program
    methods (Access = public)
        [t,x,u,p] = interpolate(obj,ns);
    end
    methods (Access = protected)
        setMesh(obj);
        cost(obj);
        defect(obj);
    end
end