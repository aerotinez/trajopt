classdef Trapezoidal < DirectCollocation
    methods (Access = protected)
        function defect(obj,k)
            X0 = obj.X{k};
            Xf = obj.X{k + 1};
            U0 = obj.U{k};
            Uf = obj.U{k + 1};
            P0 = obj.Parameters(:,k);
            Pf = obj.Parameters(:,k + 1);
            f0 = obj.Plant(X0,U0,P0);
            ff = obj.Plant(Xf,Uf,Pf);
            [t0,tf] = obj.getTimes(); 
            h = (obj.Mesh(k + 1) - obj.Mesh(k))*(tf - t0);
            nx = obj.NumStates;
            obj.Problem.subject_to(Xf - X0 - (h./2).*(f0 + ff) == zeros(nx,1));
        end
        function x = interpolateState(obj,k)
            x0 = obj.State(:,k);
            xf = obj.State(:,k + 1);
            u0 = obj.Control(:,k);
            uf = obj.Control(:,k + 1);
            p0 = obj.Parameters(:,k);
            pf = obj.Parameters(:,k + 1);
            f0 = full(obj.Plant(x0,u0,p0));
            ff = full(obj.Plant(xf,uf,pf));
            t0 = obj.Time(k);
            tf = obj.Time(k + 1);
            h = tf - t0;
            t = linspace(0,h,obj.ns);
            x = zeros(obj.NumStates,obj.ns);
            for i = 1:obj.NumStates
                A = [
                    1,0,0;
                    0,1,0;
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
            u0 = obj.Control(:,k);
            uf = obj.Control(:,k + 1);
            h = tf - t0;
            t = linspace(0,h,obj.ns);
            u = zeros(obj.NumControls,obj.ns);  
            for i = 1:obj.NumControls
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