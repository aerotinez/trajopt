classdef lg < trajopt.collocation.LegendrePseudospectral
    methods (Access = protected)
        setCollocationIndices(obj);
        setNodes(obj);
        setQuadratureWeights(obj);
        setDifferentiationMatrix(obj);
        defect(obj);
    end
end