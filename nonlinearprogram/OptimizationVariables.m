classdef OptimizationVariables < handle
    properties (GetAccess = public, SetAccess = private)
        Parameter;
        States;
        Controls;
        NumStates;
        NumControls;
    end
    properties (Access = public)
        ParameterLowerBound;
        ParameterUpperBound;
        StateLowerBounds;
        StateUpperBounds;
        ControlLowerBounds;
        ControlUpperBounds;
    end
    methods (Access = public)
        function obj = OptimizationVariables(parameter,num_states,num_controls)
            arguments
                parameter (1,1) sym;
                num_states (1,1) double;
                num_controls (1,1) double;
            end
            obj.Parameter = parameter;
            fx = @(i)str2sym(sprintf("x_%d(%s)",i,string(obj.Parameter)));
            x = arrayfun(fx,1:num_states).';
            obj.States = symfun(x,obj.Parameter);
            obj.NumStates = num_states;
            fu = @(i)str2sym(sprintf("u_%d(%s)",i,string(obj.Parameter)));
            u = arrayfun(fu,1:num_controls);
            obj.Controls = symfun(u,obj.Parameter).';
            obj.NumControls = num_controls;
            obj.ParameterLowerBound = -Inf;
            obj.ParameterUpperBound = Inf;
            obj.StateLowerBounds = -Inf(num_states,1);
            obj.StateUpperBounds = Inf(num_states,1);
            obj.ControlLowerBounds = -Inf(num_controls,1);
            obj.ControlUpperBounds = Inf(num_controls,1);
        end
        function disp(obj)
            disp("STATES:");
            disp(obj.States(obj.Parameter));
            disp("CONTROLS:");
            disp(obj.Controls(obj.Parameter));
        end
    end
end