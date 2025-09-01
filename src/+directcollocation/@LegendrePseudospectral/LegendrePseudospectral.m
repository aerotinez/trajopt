classdef LegendrePseudospectral < directcollocation.Program
    properties (GetAccess = public, SetAccess = protected)
        CollocationIndices;
        Nodes;
        QuadratureWeights;
        DifferentiationMatrix;
    end
    methods (Access = public)
        setStates(obj,states);
    end
    methods (Access = protected)
        cost(obj);
    end
    methods (Access = public, Abstract)
        [t,x,u,p] = interpolate(obj,ns);
    end
    methods (Access = protected, Abstract)
        setCollocationIndices(obj);
        setNodes(obj);
        setMesh(obj);
        setQuadratureWeights(obj);
        setDifferentiationMatrix(obj);
        defect(obj);
    end
end