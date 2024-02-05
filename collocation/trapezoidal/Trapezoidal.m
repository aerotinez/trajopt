classdef Trapezoidal < DirectCollocation
    methods (Access = public)
        function fig = plotError(obj,rows,cols)
            tnodes = obj.getTimes();
            t0 = tnodes(1:end - 1);
            tf = tnodes(2:end);
            c = cell2mat(arrayfun(@obj.discretizationError,t0,tf,'uniform',0));
            t_err = [c.Time];
            x_err = [c.State]; 
            fig = tiledlayout(rows,cols);
            tname = obj.Variables.VariableName;
            tunits = obj.Variables.VariableUnit;
            tstr = strcat(tname,sprintf(" (%s)",tunits));
            fystr = @(name,units)sprintf("%s error (%s)",name,units);
            for i = 1:obj.Variables.NumStates
                nexttile;
                plot(t_err,x_err(i,:),'k');
                xlim([tnodes(1),tnodes(end)]);
                title(strcat(obj.Variables.StateNames(i)," error"));
                xlabel(tstr);
                name = obj.Variables.StateUnitName(i);
                units = obj.Variables.StateUnits(i);
                ylabel(fystr(name,units));
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
        function err = discretizationError(obj,t0,tf)
            f = obj.Constraints.Dynamics.Plant;
            yd = @obj.interpolateStateDerivative;
            ns = 100;
            fx = @(t)obj.interpolateState(t,t0,tf);
            fu = @(t)obj.interpolateControl(t,t0,tf);
            fe = @(t,y)abs(yd(t,t0,tf) - f(fx(t),fu(t)));
            tspan = linspace(t0,tf,ns);
            [t_err,err] = ode45(fe,tspan,zeros(obj.Variables.NumStates,1));
            err = struct('Time',t_err.','State',err.');
        end
    end
end