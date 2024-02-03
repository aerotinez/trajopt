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
            t0 = obj.Variables.InitialTime;
            tf = obj.Variables.FinalTime;
            ns = 1000;
            t = linspace(t0 + 1/ns,tf - 1/ns,ns - 2);
            x = cell2mat(arrayfun(@obj.interpolateState,t,'uniform',0));
            x = [obj.Variables.State(:,1),x,obj.Variables.State(:,end)];
            u = cell2mat(arrayfun(@obj.interpolateControl,t,'uniform',0));
            u = [obj.Variables.Control(:,1),u,obj.Variables.Control(:,end)];
            t = [t0,t,tf];
            res = struct('Time',t,'State',x,'Control',u);
        end
        function t = getTimes(obj)
            t0 = obj.Variables.InitialTime;
            tf = obj.Variables.FinalTime;
            m = obj.Mesh.Mesh;
            t = [0,cumsum(diff(m).*(tf - t0))] + t0;
        end
        function idx = findIndexOfClosestTime(obj,t)
            tnodes = sort([obj.getTimes(),t]);
            if tnodes(end - 1) == tnodes(end)
                idx = numel(tnodes) - 1;
                return;
            end
            idx = find(tnodes == t) - 1;
            if size(idx,2) > 1
                idx = idx(2);
            end
        end
    end
    methods (Access = protected, Abstract)
        Ceq = defects(obj,z);
        state = interpolateState(obj);
        control = interpolateControl(obj);
    end
end