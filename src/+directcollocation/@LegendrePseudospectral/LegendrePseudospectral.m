classdef (Abstract) LegendrePseudospectral < directcollocation.Program
    properties (GetAccess = public, SetAccess = protected)
        QuadratureWeights;
        BarycentricWeights;
        DifferentiationMatrix;   
    end
    methods (Access = public, Abstract)
        [t,x,u,p] = interpolate(obj,ns);
    end
    methods (Access = protected, Abstract)
        setMesh(obj);
        setQuadratureWeights(obj);
        setBarycentricWeights(obj);
        setDifferentiationMatrix(obj);
        cost(obj);
        defect(obj);
    end
end