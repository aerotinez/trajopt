classdef OptimizationVariables
    properties (GetAccess = public, SetAccess = private)
        States;
        Controls;
    end
    methods (Access = public)
        function obj = OptimizationVariables(num_states,num_controls)
            obj.States = sym("x_",[num_states,1]);
            obj.Controls = sym("u_",[num_controls,1]);
        end
        function disp(obj)
            disp("STATES:");
            disp(obj.States.');
            disp("CONTROLS:");
            disp(obj.Controls.');
        end
    end
end