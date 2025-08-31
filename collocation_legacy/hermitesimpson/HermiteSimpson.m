classdef HermiteSimpson < DirectCollocation
    properties (Access = public)
        MidStates;
        MidControls;
    end
    methods (Access = public)
        function obj = HermiteSimpson(varargin)
            obj = obj@DirectCollocation(varargin{:});
            obj.MidStates = obj.initializeMidStates();
            obj.MidControls = obj.initializeMidControls();
        end
        function solve(obj,solver)
            arguments
                obj (1,1) HermiteSimpson;
                solver (1,1) string = "ipopt";
            end
            sol = solve@DirectCollocation(obj,solver);
            obj.MidStates.Values = sol.value(obj.MidStates.Variable);
            obj.MidControls.Values = sol.value(obj.MidControls.Variable);
        end
    end
    methods (Access = protected)
        function cost(obj)
            J = 0;
            x = obj.Plant.States.Variable; 
            u = obj.Plant.Controls.Variable;
            L = obj.Objective.Lagrange(x,u).';
            [t0,tf] = obj.getTimes();
            q = (tf - t0).*L;
            dT = diff(obj.Problem.Mesh);
            b = (1/2).*sum([dT,0;0,dT],1);
            J = J + b*q;
            M = obj.Objective.Mayer(x(:,1),t0,x(:,end),tf);
            J = J + M;
            obj.Problem.Problem.minimize(J);
        end
        function defect(obj)
            x0 = obj.Plant.States.Variable(:,1:end - 1);
            xc = obj.MidStates.Variable;
            xf = obj.Plant.States.Variable(:,2:end);
            u0 = obj.Plant.Controls.Variable(:,1:end - 1);
            uc = obj.MidControls.Variable;
            uf = obj.Plant.Controls.Variable(:,2:end);
            p0 = obj.Plant.Parameters(:,1:end - 1);
            pf = obj.Plant.Parameters(:,2:end);
            f0 = obj.Plant.Dynamics(x0,u0,p0);
            fc = obj.Plant.Dynamics(xc,uc,p0);
            ff = obj.Plant.Dynamics(xf,uf,pf);
            [t0,tf] = obj.getTimes();
            h = diff(obj.Problem.Mesh(1:2))*(tf - t0);
            Cf = xf - (x0 + (h/6).*(f0 + 4*fc + ff));
            Cc = xc - ((1/2).*(x0 + xf) + (h/8).*(f0 - ff));
            obj.Problem.Problem.subject_to([Cf;Cc] == 0);
        end
        function setTime(obj)
            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;
            obj.Time = linspace(t0,tf,obj.Problem.NumNodes);
        end
        function t = interpolateTime(obj)
            t = zeros(1,(obj.Problem.NumNodes - 1)*obj.ns);
            for k = 1:obj.Problem.NumNodes - 1
                t0 = obj.Time(k);
                tf = obj.Time(k + 1);
                t((k - 1)*obj.ns + 1:k*obj.ns) = linspace(t0,tf,obj.ns);
            end 
        end
        function x = interpolateState(obj,k)
            x0 = obj.Plant.States.getValues(k);
            xc = obj.MidStates.Values(:,k);
            xf = obj.Plant.States.getValues(k + 1);
            u0 = obj.Plant.Controls.getValues(k);
            uc = obj.MidControls.Values(:,k);
            uf = obj.Plant.Controls.getValues(k + 1);
            p0 = obj.Plant.Parameters(:,k);
            pf = obj.Plant.Parameters(:,k + 1);
            f0 = full(obj.Plant.Dynamics(x0,u0,p0));
            fc = full(obj.Plant.Dynamics(xc,uc,p0));
            ff = full(obj.Plant.Dynamics(xf,uf,pf)); 
            h = obj.Time(k + 1) - obj.Time(k);
            h0 = 0;
            hc = h/2;
            t = linspace(h0,h,obj.ns);
            x = zeros(obj.Plant.NumStates,obj.ns);
            for i = 1:obj.Plant.NumStates
                A = [
                    1,h0,h0^2,h0^3;
                    0,1,2*h0,3*h0^2;
                    1,hc,hc^2,hc^3;
                    0,1,2*hc,3*hc^2;
                    1,h,h^2,h^3;
                    0,1,2*h,3*h^2; 
                ];

                b = [
                    x0(i);
                    f0(i);
                    xc(i);
                    fc(i);
                    xf(i);
                    ff(i);
                ];

                a = A\b;

                x(i,:) = a(1) + a(2).*t + a(3).*t.^2 + a(4).*t.^3;
            end
        end
        function u = interpolateControl(obj,k) 
            u0 = obj.Plant.Controls.getValues(k);
            uc = obj.MidControls.Values(:,k);
            uf = obj.Plant.Controls.getValues(k + 1);
            h = obj.Time(k + 1) - obj.Time(k);
            h0 = 0;
            hc = h/2;
            t = linspace(h0,h,obj.ns);
            u = zeros(obj.Plant.NumControls,obj.ns);
            for i = 1:obj.Plant.NumControls
                A = [
                    1,h0,h0^2;
                    1,hc,hc^2;
                    1,h,h^2;
                ];

                b = [
                    u0(i);
                    uc(i);
                    uf(i);
                ];

                a = A\b;

                u(i,:) = a(1) + a(2).*t + a(3).*t.^2;
            end
        end
        function [t,x,u] = interpolate(obj)
            t = obj.interpolateTime();
            x = zeros(obj.Plant.NumStates,numel(t));
            u = zeros(obj.Plant.NumControls,numel(t));
            for k = 1:obj.Problem.NumNodes - 1
                x(:,(k - 1)*obj.ns + 1:k*obj.ns) = obj.interpolateState(k);
                u(:,(k - 1)*obj.ns + 1:k*obj.ns) = obj.interpolateControl(k);
            end
        end
    end
    methods (Access = private)
        function xc = initializeMidStates(obj)
            x = obj.Plant.States.getValues();
            x0 = x(:,1:end - 1);
            x1 = x(:,2:end);
            values = (x0 + x1)./2;
            initial = nan(obj.Plant.NumStates,1);
            final = nan(obj.Plant.NumStates,1);
            lower = [obj.Plant.States.States.LowerBound].';
            upper = [obj.Plant.States.States.UpperBound].';
            f = @CollocationVariableFactory;
            B = f(obj.Problem.Problem,values,initial,final,lower,upper);
            xc = struct("Values",values,"Variable",B.create());
        end
        function uc = initializeMidControls(obj)
            u = obj.Plant.Controls.getValues();
            u0 = u(:,1:end - 1);
            u1 = u(:,2:end);
            values = (u0 + u1)./2;
            initial = nan(obj.Plant.NumControls,1);
            final = nan(obj.Plant.NumControls,1);
            lower = [obj.Plant.Controls.States.LowerBound].';
            upper = [obj.Plant.Controls.States.UpperBound].';
            f = @CollocationVariableFactory;
            B = f(obj.Problem.Problem,values,initial,final,lower,upper);
            uc = struct("Values",values,"Variable",B.create());
        end
    end
end