classdef Plant
    properties (GetAccess = public, SetAccess = private)
        Dynamics;
        InitialState;
        FinalState;
        Parameters;
        NumStates;
        NumControls;
    end
    methods (Access = public)
        function obj = Plant(dynamics,initial_state,final_state,num_controls,parameters)
            arguments
                dynamics (1,1) function_handle;
                initial_state (:,1);
                final_state (:,1);
                num_controls (1,1) double;
                parameters (:,1) double;
            end
            obj.NumStates = size(initial_state,1);
            obj.NumControls = num_controls;
            obj.InitialState = initial_state;
            obj.FinalState = final_state;
            obj.Parameters = parameters;
            obj.Dynamics = @(x,u)dynamics(x,u,obj.Parameters);
        end
    end
end