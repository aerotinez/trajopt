classdef TrapezoidalCollocation
    properties (GetAccess = public, SetAccess = private)
        Plant;
        Vars;
        FinalTime;
        NumNodes;
        NumStates;
        NumControls;
    end
    methods (Access = public)
        function obj = TrapezoidalCollocation(f,nx,nu,params,N,tf)
            arguments
                f (1,1) function_handle;
                nx (1,1) double {mustBeInteger,mustBePositive};
                nu (1,1) double {mustBeInteger,mustBePositive};
                params (:,1) double {mustBeNumeric};
                N (1,1) double {mustBeInteger,mustBePositive};
                tf (1,1) = sym("t_f");
            end
            obj.FinalTime = tf;
            obj.NumNodes = N;
            obj.NumStates = nx;
            obj.NumControls = nu;
            indx = 1:obj.NumStates;
            indu = obj.NumStates + 1:obj.NumStates + obj.NumControls;
            obj.Plant = @(y)f(y(indx),y(indu),params);
        end
    end
    methods (Access = private)
        
    end
end