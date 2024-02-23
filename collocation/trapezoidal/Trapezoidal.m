classdef Trapezoidal < DirectCollocation
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
            xf = obj.Plant.States.Variable(:,2:end);
            u0 = obj.Plant.Controls.Variable(:,1:end - 1);
            uf = obj.Plant.Controls.Variable(:,2:end);
            p0 = obj.Plant.Parameters(:,1:end - 1);
            pf = obj.Plant.Parameters(:,2:end);
            f0 = obj.Plant.Dynamics(x0,u0,p0);
            ff = obj.Plant.Dynamics(xf,uf,pf);
            [t0,tf] = obj.getTimes();
            h = diff(obj.Problem.Mesh(1:2))*(tf - t0); 
            obj.Problem.Problem.subject_to(xf - (x0 + (h/2).*(f0 + ff)) == 0);
        end
        function x = interpolateState(obj,k)
            x0 = obj.Plant.States.getValues(k);
            xf = obj.Plant.States.getValues(k + 1);
            u0 = obj.Plant.Controls.getValues(k);
            uf = obj.Plant.Controls.getValues(k + 1);
            p0 = obj.Plant.Parameters(:,k);
            pf = obj.Plant.Parameters(:,k + 1);
            f0 = full(obj.Plant.Dynamics(x0,u0,p0));
            ff = full(obj.Plant.Dynamics(xf,uf,pf));
            h0 = 0;
            h = obj.Time(k + 1) - obj.Time(k);
            t = linspace(h0,h,obj.ns);
            x = zeros(obj.Plant.NumStates,obj.ns);
            for i = 1:obj.Plant.NumStates
                A = [
                    1,h0,h0^2;
                    0,1,2*h0;
                    1,h,h^2;
                    0,1,2*h;
                ];

                b = [
                    x0(i);
                    f0(i);
                    xf(i);
                    ff(i);
                ];

                a = A\b;

                x(i,:) = a(1) + a(2)*t + a(3)*t.^2;
            end
        end
        function u = interpolateControl(obj,k)
            t0 = obj.Time(k);
            tf = obj.Time(k + 1);
            u0 = obj.Plant.Controls.getValues(k);
            uf = obj.Plant.Controls.getValues(k + 1);
            h = tf - t0;
            t = linspace(0,h,obj.ns);
            u = zeros(obj.Plant.NumControls,obj.ns);  
            for i = 1:obj.Plant.NumControls
                A = [
                    1,0;
                    1,h;
                ];

                b = [
                    u0(i);
                    uf(i);
                ];

                a = A\b;

                u(i,:) = a(1) + a(2)*t;
            end
        end
    end
end