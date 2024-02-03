classdef dyncon
    properties (GetAccess = public, SetAccess = private)
        % Plant dynamics
        %   Function prototype: 
        %       x_dot = dynamics(x,u)
        %   where:
        %       x - state vector
        %       u - input vector
        Plant;
    end
    properties (Access = private)
        Vars;
    end
    methods (Access = public)
        function obj = dyncon(vars,plant)
            arguments
                vars (1,1) ocpvars;
                plant (1,1) function_handle; 
            end
            obj.Vars = vars;
            obj.Plant = plant;
        end
        function disp(obj)
            [t,x,u] = obj.Vars.sym();
            xd = diff(x,t);
            consoletitle('Dynamics','=');
            arrayfun(@disp,xd == simplify(expand(obj.Plant(x,u))));
        end 
    end 
end