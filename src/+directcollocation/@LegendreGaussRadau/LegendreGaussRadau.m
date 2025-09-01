classdef LegendreGaussRadau < directcollocation.LegendrePseudospectral
    properties (GetAccess = public, SetAccess = private)
        IncludedEndPoint;
    end
    methods (Access = public)
        function obj = LegendreGaussRadau(num_nodes,included_end_point)
            arguments
                num_nodes (1,1) double {mustBeInteger,mustBePositive};
                included_end_point (1,1) {mustBeMember(included_end_point,[-1,1])};
            end
            obj@directcollocation.LegendrePseudospectral(num_nodes);
            obj.IncludedEndPoint = included_end_point;
        end
    end
    methods (Access = public)
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