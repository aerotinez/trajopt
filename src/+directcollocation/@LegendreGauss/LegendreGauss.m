classdef LegendreGauss < directcollocation.LegendrePseudospectral
    properties (Access = private)
        StartStateVals   % nx×1 double, NaN where free
        EndStateVals     % nx×1 double, NaN where free
    end
    methods (Access = public)
        [t,x,u,p] = interpolate(obj,ns);
    end
    methods (Access = protected)
        setMesh(obj);
        setQuadratureWeights(obj);
        setBarycentricWeights(obj);
        setDifferentiationMatrix(obj);
        cost(obj);
        defect(obj);
    end
end