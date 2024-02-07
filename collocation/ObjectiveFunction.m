classdef ObjectiveFunction < handle
    properties (GetAccess = public, SetAccess = private)
        Lagrange;
        Mayer;
    end
    methods (Access = public) 
        function setLagrange(obj,f,x,u)
            arguments
                obj ObjectiveFunction;
                f (1,1);
                x (:,1) casadi.MX;
                u (:,1) casadi.MX;
            end
            name = 'Lagrange';
            vars = {x,u};
            inputs = {'x','u'};
            outputs = {'L'};
            obj.Lagrange = casadi.Function(name,vars,{f},inputs,outputs);
        end
        function setMayer(obj,f,t0,x0,tf,xf)
            arguments
                obj ObjectiveFunction;
                f (1,1);
                t0 (1,1) casadi.MX;
                x0 (:,1) casadi.MX;
                tf (1,1) casadi.MX;
                xf (:,1) casadi.MX;
            end
            name = 'Mayer';
            vars = {t0,x0,tf,xf};
            inputs = {'t0','x0','tf','xf'};
            outputs = {'M'};
            obj.Mayer = casadi.Function(name,vars,{f},inputs,outputs);
        end 
    end
end