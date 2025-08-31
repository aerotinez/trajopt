classdef HermiteSimpson < directcollocation.Program
    properties (GetAccess = public, SetAccess = private)
        MidStates;
        MidControls;
    end
    methods (Access = public)
        function obj = HermiteSimpson(num_nodes)
            arguments
                num_nodes (1,1) double {mustBeInteger,mustBePositive};
            end
            validateattributes(num_nodes,{'double'},{'scalar','odd'},mfilename,'num_nodes');
            obj@directcollocation.Program(num_nodes);
        end
        [t,x,u,p] = interpolate(obj,ns);
    end
    methods (Access = protected)
        setMesh(obj);
        cost(obj);
        defect(obj);
    end
end