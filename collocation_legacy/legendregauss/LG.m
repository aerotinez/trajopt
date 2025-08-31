classdef LG < DirectCollocation
    methods (Access = public)
        function t = interpolateTime(obj)
            t0 = obj.Time(1);
            tf = obj.Time(end);
            t = linspace(t0,tf,obj.Problem.NumNodes*obj.ns);
        end
        function x = interpolateState(obj,t)
            x = obj.interpolateVar(obj.Plant.States,t); 
        end
        function u = interpolateControl(obj,t)
            u = obj.interpolateVar(obj.Plant.Controls,t); 
        end
        function [t,x,u] = interpolate(obj)
            t = obj.interpolateTime();
            x = obj.interpolateState(t);
            u = obj.interpolateControl(t);
        end
        function [t,x] = simulatePlant(obj)
            X = obj.Plant.States.getValues();
            x0 = X(:,1);
            p = obj.Plant.Parameters(:,1);
            fu = @obj.interpolateControl;
            f = @(t,y)full(obj.Plant.Dynamics(y,fu(t),p));
            tspan = [obj.Time(1),obj.Time(end)];
            [t,x] = ode45(f,tspan,x0);
            t = t.';
            x = x.';
        end
    end
    methods (Access = protected)
        function setTime(obj)
            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;
            tau = unique([-1,obj.collocationPoints(),1]);
            obj.Time = (tf - t0)/2.*tau + (tf + t0)/2;
        end
        function tau = transposeTimeDomain(obj,t)
            t0 = obj.Time(1);
            tf = obj.Time(end);
            dt = tf - t0;
            tau = (2.*t - dt)./dt;
        end
        function x = interpolateVar(obj,var,t)
            tau_k = obj.collocationPoints();
            tau = obj.transposeTimeDomain(t);
            xk = var.getValues();
            L = lagpol(unique([-1,tau_k,1]),tau);
            x = xk*L;
        end 
    end
    methods (Access = protected, Abstract)
        tau = collocationPoints(obj);
        cost(obj);
        defect(obj);
    end
end