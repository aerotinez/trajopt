classdef TrapezoidalCollocation < nlp 
    methods (Access = protected) 
        function Ceq = dynamicConstraints(obj,z)
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
        function res = interpolate(obj)
            t0 = obj.Variables.InitialTime;
            tf = obj.Variables.FinalTime;
            ns = 1000;
            t = linspace(t0 + 1/ns,tf - 1/ns,ns - 2);
            x = cell2mat(arrayfun(@obj.interpolateState,t,'uniform',0));
            x = [obj.Variables.State(:,1),x,obj.Variables.State(:,end)];
            u = cell2mat(arrayfun(@obj.inertpolateControl,t,'uniform',0));
            u = [obj.Variables.Control(:,1),u,obj.Variables.Control(:,end)];
            t = [t0,t,tf];
            res = struct('Time',t,'State',x,'Control',u);
        end
    end
    methods (Access = public)
        function t = getTimes(obj)
            t0 = obj.Variables.InitialTime;
            tf = obj.Variables.FinalTime;
            m = obj.Mesh.Mesh;
            t = [0,cumsum(diff(m).*(tf - t0))] + t0;
        end
        function idx = findIndexOfClosestTime(obj,t)
            tnodes = sort([obj.getTimes(),t]); 
            idx = find(tnodes == t) - 1;
            if size(idx,2) > 1
                idx = idx(2);
            end
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
        function u = inertpolateControl(obj,ti)
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