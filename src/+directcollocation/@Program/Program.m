classdef (Abstract) Program < handle
    properties (GetAccess = public, SetAccess = protected)
        Problem;
        Mesh;
        NumNodes;
        NumIntervals;
        NumStates;
        NumControls;
        NumParameters;
        States;
        InitialTime;
        IsInitialTimeFree;
        FinalTime;
        IsFinalTimeFree;
        IsInitialStateFree;
        IsFinalStateFree;
        Controls;
        Parameters;
        Plant;
        LagrangeCost;
        MayerCost;
        Solution;
    end
    methods (Access = public)
        function obj = Program(num_nodes) 
            arguments
                num_nodes (1,1) double {mustBeInteger,mustBePositive};
            end
            obj.Problem = casadi.Opti();
            obj.NumNodes = num_nodes;
        end
        setStates(obj,states);
        setControls(obj,controls);
        setInitialTime(obj,initial_time);
        setFinalTime(obj,final_time);
        setParameters(obj,params);
        setPlant(obj,f);
        setObjective(obj,lagrange_fun,mayer_fun);
        solve(obj);
    end
    methods (Access = public, Abstract)
        [t,x,u,p] = interpolate(obj,ns);
    end
    methods (Access = protected, Abstract)
        setMesh(obj);
        cost(obj);
        defect(obj);
    end
    methods (Access = protected)
        setVariable(obj,vars,vars_tab);
        J = smoothCost(obj,a,b,c);
    end
end
