classdef dyncon
    properties (GetAccess = public, SetAccess = private)
        % Plant dynamics
        %   Function prototype: 
        %       x_dot = dynamics(x,u,t,vp)
        %   where:
        %       x - state vector
        %       u - input vector
        %       t - time
        %       p - varying parameter vector
        Plant;
        Parameters;
    end
    properties (Access = private)
        Vars;
    end
    methods (Access = public)
        function obj = dyncon(vars,plant,parameters)
            arguments
                vars (1,1) ocpvars;
                plant (1,1) function_handle;
                parameters (:,1) optparam; 
            end
            obj.Vars = vars;
            obj.Plant = plant;
            obj.Parameters = parameters;
        end
        function disp(obj)
            [t,x,u] = obj.Vars.sym();
            xd = diff(x,t);
            p = [obj.Parameters.sym()].';
            consoletitle('Dynamics','=');
            arrayfun(@disp,xd == obj.Plant(x,u,t,p));
        end 
    end 
end