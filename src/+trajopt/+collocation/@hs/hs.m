classdef hs < trajopt.collocation.Program
    properties (GetAccess = public, SetAccess = private)
        MidStates;
        MidControls;
    end
    methods (Access = public)
        function obj = hs(num_nodes)
            arguments
                num_nodes (1,1) double {mustBeInteger,mustBePositive};
            end
            validateattributes(num_nodes,{'double'},{'scalar','odd'},mfilename,'num_nodes');
            obj@trajopt.collocation.Program(num_nodes);
        end
    end
    methods (Access = protected)
        setMesh(obj);
        cost(obj);
        defect(obj);
    end
end