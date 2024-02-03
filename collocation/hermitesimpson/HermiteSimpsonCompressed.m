classdef HermiteSimpsonCompressed < DirectCollocation
    methods (Access = protected)
        function Ceq = defects(obj,z)
            [t0,tf,x,u] = obj.Variables.unpack(z);
            x0 = x(:,1:end-1);
            u0 = u(:,1:end-1);
            xf = x(:,2:end);
            uf = u(:,2:end);
            f = obj.Constraints.Dynamics.Plant;
            f0 = f(x0,u0);
            ff = f(xf,uf);
            h = diff(obj.Mesh.Mesh).*(tf - t0);
            xc = (1/2).*(xf + x0) + (h./8).*(f0 - ff);
            uc = 
        end
        function x = interpolateState(obj)
        end
        function u = interpolateControl(obj)
        end
    end
end