classdef LegendreGaussRadau < directcollocation.LegendrePseudospectral
    properties (GetAccess = public, SetAccess = private)
        EndPoint   % 0 -> include s=0;  1 -> include s=1
    end
    properties (Access = private)
        EndStateVals   % nx×1 double, boundary values for the MISSING endpoint
    end

    methods (Access = public)
        function obj = LegendreGaussRadau(num_nodes, end_point)
            arguments
                num_nodes (1,1) double {mustBeInteger,mustBePositive};
                end_point (1,1) double {mustBeMember(end_point,[0,1])};
            end
            obj@directcollocation.LegendrePseudospectral(num_nodes);
            obj.EndPoint = end_point;
        end

        setStates(obj,states);
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
