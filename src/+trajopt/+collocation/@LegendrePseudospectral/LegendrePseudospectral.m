classdef LegendrePseudospectral < trajopt.collocation.Program
    properties (GetAccess = public, SetAccess = protected)
        CollocationIndices;
        Nodes;
        QuadratureWeights;
        DifferentiationMatrix;
    end
    methods (Access = public)
        function obj = LegendrePseudospectral(varargin)
            obj@trajopt.collocation.Program(varargin{1});
        end
    end
    methods (Access = protected)
        cost(obj);
        setMesh(obj);
        J = smoothCost(obj);
    end
    methods (Access = protected, Abstract)
        setCollocationIndices(obj);
        setNodes(obj);
        setQuadratureWeights(obj);
        setDifferentiationMatrix(obj);
        defect(obj);
    end
end