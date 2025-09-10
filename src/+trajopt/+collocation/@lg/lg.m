classdef lg < trajopt.collocation.LegendrePseudospectral
    methods (Access = public)
        function obj = lg(num_nodes)
            arguments
                num_nodes (1,1) double {mustBeInteger,mustBePositive};
            end
            obj@trajopt.collocation.LegendrePseudospectral(num_nodes);
            setCollocationIndices(obj);
            setNodes(obj);
            setMesh(obj);
            setQuadratureWeights(obj);
            setDifferentiationMatrix(obj);
        end
    end
    methods (Access = public)
        setControls(obj,controls);
        setParameters(obj,params);
    end
    methods (Access = protected)
        setCollocationIndices(obj);
        setNodes(obj);
        setQuadratureWeights(obj);
        setDifferentiationMatrix(obj);
        defect(obj);
    end
end