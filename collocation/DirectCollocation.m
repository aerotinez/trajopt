classdef DirectCollocation < nlp
    methods (Access = public)
        function fig = plot(obj,rows,cols)
            results = obj.interpolate();
            t = results.Time;
            z = [
                results.State;
                results.Control;
                ];
            fig = obj.Variables.plot(obj.Mesh,rows,cols);
            axelist = flipud(fig.Children.Children);
            for i = 1:numel(axelist)
                hold(axelist(i),'on');
                l = plot(axelist(i),t,z(i,:),"k","LineWidth",2);
                uistack(l,'bottom');
                hold(axelist(i),'off');
            end
        end 
    end
    methods (Access = protected)
        function Ceq = dynamicConstraints(obj,z)
            Ceq = obj.defects(z);
        end
        function res = interpolate(obj)
            tnodes = obj.getTimes();
            t0 = tnodes(:,1:end - 1).';
            tf = tnodes(:,2:end).'; 
            ns = 100;
            ft = @(t0,tf)linspace(t0,tf,ns);
            tc = arrayfun(ft,t0,tf,'UniformOutput',false);
            t0c = num2cell(t0);
            tfc = num2cell(tf);
            fx = @(t,t0,tf)obj.interpolateState(t,t0,tf).';
            x = cell2mat(cellfun(fx,tc,t0c,tfc,'uniform',0)).';
            fu = @(t,t0,tf)obj.interpolateControl(t,t0,tf).';
            u = cell2mat(cellfun(fu,tc,t0c,tfc,'uniform',0)).';
            t = cell2mat(tc.');
            res = struct('Time',t,'State',x,'Control',u); 
        end
        function t = getTimes(obj)
            t0 = obj.Variables.InitialTime;
            tf = obj.Variables.FinalTime;
            m = obj.Mesh.Mesh;
            t = [0,cumsum(diff(m).*(tf - t0))] + t0;
        end 
    end
    methods (Access = protected, Abstract)
        Ceq = defects(obj,z);
        state = interpolateState(obj);
        control = interpolateControl(obj);
    end
end