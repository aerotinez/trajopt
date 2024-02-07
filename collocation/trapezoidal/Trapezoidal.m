classdef Trapezoidal < DirectCollocation
    methods (Access = protected)
        function defect(obj,i)
            X0 = obj.X{i};
            Xf = obj.X{i + 1};
            U0 = obj.U{i};
            Uf = obj.U{i + 1};
            P0 = obj.Parameters(:,i);
            Pf = obj.Parameters(:,i + 1);
            f0 = obj.Plant(X0,U0,P0);
            ff = obj.Plant(Xf,Uf,Pf);
            [t0,tf] = obj.getTimes(); 
            h = (obj.Mesh(i + 1) - obj.Mesh(i))*(tf - t0);
            nx = obj.NumStates;
            obj.Problem.subject_to(Xf - X0 - (h./2).*(f0 + ff) == zeros(nx,1));
        end
        function x = interpolateState(obj,i)
            X0 = obj.State(:,i);
            Xf = obj.State(:,i + 1);
            U0 = obj.Control(:,i);
            Uf = obj.Control(:,i + 1);
            P0 = obj.Parameters(:,i);
            Pf = obj.Parameters(:,i + 1);
            f0 = full(obj.Plant(X0,U0,P0));
            ff = full(obj.Plant(Xf,Uf,Pf));
            t0 = obj.Time(i);
            tf = obj.Time(i + 1); 
            t = linspace(t0,tf,obj.ns);
            T = t - t0;
            h = tf - t0;
            a0 = T;
            a1 = (T.^2)./(2.*h);
            x = X0 + a0.*f0 + a1.*(ff - f0);
        end
        function u = interpolateControl(obj,i)
            t0 = obj.Time(i);
            tf = obj.Time(i + 1);
            t = linspace(t0,tf,obj.ns);
            T = (t - t0)./(tf - t0);
            U0 = obj.Control(:,i);
            Uf = obj.Control(:,i + 1);
            u = U0 + (Uf - U0).*T;
        end 
    end
end