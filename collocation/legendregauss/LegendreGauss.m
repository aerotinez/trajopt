classdef LegendreGauss < DirectCollocation  
    methods (Access = protected)
        function cost(obj)
            J = 0;
            w = obj.quadratureWeights(); 
            X = obj.Plant.States.Variable(:,1:end - 1);
            U = obj.Plant.Controls.Variable(:,1:end - 1);
            XLG = X(:,2:end);
            ULG = U(:,2:end);
            L = obj.Objective.Lagrange(XLG,ULG).';
            [t0,tf] = obj.getTimes();
            J = J + ((tf - t0)/2).*(w*L);
            M = obj.Objective.Mayer(X(:,1),t0,X(:,end),tf);
            J = J + M;
            obj.Problem.Problem.minimize(J);
        end
        function defect(obj)
            N = obj.Problem.NumNodes - 2;
            tau = sort(roots(legpol(N))).';
            D = lagpoldiff([-1,tau],tau);
            X = obj.Plant.States.Variable(:,1:end - 1);
            U = obj.Plant.Controls.Variable(:,1:end - 1);
            P = obj.Plant.Parameters(:,1:end - 1);
            XLG = X(:,2:end);
            ULG = U(:,2:end);
            PLG = P(:,2:end);
            F = obj.Plant.Dynamics;
            [t0,tf] = obj.getTimes();
            dt = (tf - t0)./2;
            obj.Problem.Problem.subject_to(dt.*F(XLG,ULG,PLG) - X*D == 0);
            w = obj.quadratureWeights().';
            X0 = X(:,1);
            Xf = obj.Plant.States.Variable(:,end);
            obj.Problem.Problem.subject_to(Xf == X0 + dt.*F(XLG,ULG,PLG)*w);
        end
        function setTime(obj)
            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;
            tau = [-1,sort(roots(legpol(obj.Problem.NumNodes - 2))).',1];
            obj.Time = (tf - t0)/2.*tau + (tf + t0)/2;
        end
        function t = interpolateTime(obj)
            t0 = obj.Time(1);
            tf = obj.Time(end);
            t = linspace(t0,tf,obj.Problem.NumNodes*obj.ns);
        end
        function x = interpolateState(obj)
            N = obj.Problem.NumNodes - 2;
            tau_k = sort(roots(legpol(N))).';
            tau = obj.transposeTimeDomain();
            xi = obj.Plant.States.getValues();
            L = lagpol([-1,tau_k,1],tau);
            x = xi*L;
        end
        function u = interpolateControl(obj)
            N = obj.Problem.NumNodes - 2;
            tau_k = sort(roots(legpol(N))).';
            tau = obj.transposeTimeDomain();
            ui = obj.Plant.Controls.getValues();
            L = lagpol([-1,tau_k,1],tau);
            u = ui*L;
        end
        function [t,x,u] = interpolate(obj)
            t = obj.interpolateTime();
            x = obj.interpolateState();
            u = obj.interpolateControl();
        end
    end
    methods (Access = private)
        function tau = transposeTimeDomain(obj)
            t0 = obj.Time(1);
            tf = obj.Time(end);
            dt = tf - t0;
            t = obj.interpolateTime();
            tau = (2.*t - dt)./dt;
        end
        function w = quadratureWeights(obj)
            N = obj.Problem.NumNodes - 2;
            tau = sort(roots(legpol(N))).';
            dPN = (fliplr(0:N).*legpol(N))*[tau.^(fliplr(0:N-1).');zeros(1,N)];
            w = 2./((1 - tau.^2).*dPN.^2);
        end
    end
end