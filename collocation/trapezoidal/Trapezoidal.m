classdef Trapezoidal < DirectCollocation
    methods (Access = public)
        function fig = plotError(obj,rows,cols)
            f = obj.Constraints.Dynamics.Plant;
            yd = @obj.interpolateStateDerivative;
            tnodes = obj.getTimes();
            t0 = tnodes(1:end - 1);
            tf = tnodes(2:end);
            ns = 100;
            nx = obj.Variables.NumStates;
            N = obj.Variables.NumPoints;
            t_err = zeros(1,ns*(N - 1));
            x_err = zeros(nx,ns*(N - 1));
            for i = 1:N - 1
                fx = @(t)obj.interpolateState(t,t0(i),tf(i));
                fu = @(t)obj.interpolateControl(t,t0(i),tf(i));
                fe = @(t,y)abs(yd(t,t0(i),tf(i)) - f(fx(t),fu(t)));
                tspan = linspace(t0(i),tf(i),ns);
                [ti,yi] = ode45(fe,tspan,zeros(nx,1));
                t_err(:,ns*i - ns + 1:ns*i) = ti.';
                x_err(:,ns*i - ns + 1:ns*i) = yi.';
            end 
            fig = tiledlayout(rows,cols);
            for i = 1:nx
                nexttile;
                plot(t_err,x_err(i,:));
                xlim([tnodes(1),tnodes(end)]);
            end
        end
    end 
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
        function x = interpolateState(obj,ti,t0,tf)
            t = obj.getTimes();
            idx0 = t == t0;
            idxf = t == tf;
            f = obj.Constraints.Dynamics.Plant;
            x0 = obj.Variables.State(:,idx0);
            u0 = obj.Variables.Control(:,idx0);
            xf = obj.Variables.State(:,idxf);
            uf = obj.Variables.Control(:,idxf);
            f0 = f(x0,u0);
            ff = f(xf,uf);
            T = ti - t0;
            h = tf - t0;
            x = x0 + T.*f0 + ((T.^2)./(2.*h)).*(ff - f0);
        end
        function u = interpolateControl(obj,ti,t0,tf)
            t = obj.getTimes();
            idx0 = t == t0;
            idxf = t == tf;
            u0 = obj.Variables.Control(:,idx0);
            uf = obj.Variables.Control(:,idxf);
            T = (ti - t0)./(tf - t0);
            u = u0 + T.*(uf - u0);
        end
        function x_dot = interpolateStateDerivative(obj,ti,t0,tf)
            t = obj.getTimes();
            idx0 = t == t0;
            idxf = t == tf;
            f = obj.Constraints.Dynamics.Plant;
            x0 = obj.Variables.State(:,idx0);
            u0 = obj.Variables.Control(:,idx0);
            xf = obj.Variables.State(:,idxf);
            uf = obj.Variables.Control(:,idxf);
            f0 = f(x0,u0);
            ff = f(xf,uf);
            a1 = (f0 - ff)./(t0 - tf);
            a0 = -(f0.*tf - ff.*t0)./(t0 - tf);
            x_dot = a1.*ti + a0;
        end
    end
end