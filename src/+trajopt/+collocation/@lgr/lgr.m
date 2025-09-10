classdef lgr < trajopt.collocation.LegendrePseudospectral
    properties (GetAccess = public, SetAccess = private)
        IncludedEndPoint;
    end
    methods (Access = public)
        function obj = lgr(num_nodes,included_end_point)
            arguments
                num_nodes (1,1) double {mustBeInteger,mustBePositive};
                included_end_point (1,1) {mustBeMember(included_end_point,[-1,1])};
            end
            obj@trajopt.collocation.LegendrePseudospectral(num_nodes);
            obj.IncludedEndPoint = included_end_point;
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