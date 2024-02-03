classdef Trapezoidal < DirectCollocation 
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
            defect = xf - x0 - (h/2).*(f0 + ff);
            Ceq = reshape(defect,[],1);
        end  
        function x = interpolateState(obj,ti)
            idx = obj.findIndexOfClosestTime(ti);
            t = obj.getTimes();
            t0 = t(idx);
            tf = t(idx + 1);
            f = obj.Constraints.Dynamics.Plant;
            x0 = obj.Variables.State(:,idx);
            u0 = obj.Variables.Control(:,idx);
            xf = obj.Variables.State(:,idx + 1);
            uf = obj.Variables.Control(:,idx + 1);
            f0 = f(x0,u0);
            ff = f(xf,uf);
            T = ti - t0;
            h = tf - t0;
            x = x0 + T.*f0 + ((T^2)/(2*h)).*(ff - f0);
        end
        function u = interpolateControl(obj,ti)
            idx = obj.findIndexOfClosestTime(ti);
            t = obj.getTimes();
            t0 = t(idx);
            tf = t(idx + 1);
            u0 = obj.Variables.Control(:,idx);
            uf = obj.Variables.Control(:,idx + 1);
            T = (ti - t0)/(tf - t0);
            u = u0 + T.*(uf - u0);
        end 
    end
end