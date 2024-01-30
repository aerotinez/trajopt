classdef OptimizationVariables < handle
    properties (GetAccess = public, SetAccess = private)
        Variable;
        States;
        Controls;
    end
    properties (Access = public)
        VariableLowerBound;
        VariableUpperBound;
        StateLowerBounds;
        StateUpperBounds;
        ControlLowerBounds;
        ControlUpperBounds;
    end
    methods (Access = public)
        function obj = OptimizationVariables(variable,num_states,num_controls)
            obj.Variable = variable;
            fx = @(i)str2sym(sprintf("x_%d(%s)",i,string(obj.Variable)));
            x = arrayfun(fx,1:num_states).';
            obj.States = symfun(x,obj.Variable);
            fu = @(i)str2sym(sprintf("u_%d(%s)",i,string(obj.Variable)));
            u = arrayfun(fu,1:num_controls);
            obj.Controls = symfun(u,obj.Variable).'; 
        end
        function disp(obj)
            disp("STATES:");
            disp(obj.States(obj.Variable));
            disp("CONTROLS:");
            disp(obj.Controls(obj.Variable));
        end
    end
end