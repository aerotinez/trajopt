classdef LegendreGauss < directcollocation.LegendrePseudospectral
    methods (Access = public)
        setStates(obj,states);
        [t,x,u,p] = interpolate(obj,ns);
    end
    methods (Access = protected)
        setCollocationIndices(obj);
        setNodes(obj);
        setMesh(obj);
        setQuadratureWeights(obj);
        setDifferentiationMatrix(obj);
        defect(obj);
        cost(obj);
    end
end