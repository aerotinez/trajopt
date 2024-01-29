classdef Plant
    properties (GetAccess = public, SetAccess = private)
        Dynamics;
        Parameters; 
    end
    properties (Access = private)
        x;
        xdot;
        u;
    end
    methods (Access = public)
        function obj = Plant(optimization_variables,dynamics,parameters)
            arguments
                optimization_variables (1,1) OptimizationVariables;
                dynamics (1,1) function_handle;
                parameters (:,1) double; 
            end
            obj.x = optimization_variables.States;
            obj.xdot = sym("x_dot_",[numel(optimization_variables.States),1]);
            obj.u = optimization_variables.Controls;
            obj.Parameters = parameters; 
            obj.Dynamics = @(x,u)dynamics(x,u,obj.Parameters); 
        end
        function disp(obj)
            disp("PLANT DYNAMICS:")
            disp(obj.xdot == simplify(expand(obj.Dynamics(obj.x,obj.u))));
        end
    end
end