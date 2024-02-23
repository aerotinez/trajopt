classdef DirectCollocation < handle
    properties (GetAccess = public, SetAccess = protected)
        Problem;
        Objective;
        Plant;
        InitialTime;
        FinalTime;
        Time;
        ns = 100;
    end  
    methods (Access = public)
        function obj = DirectCollocation(prob,objfun,plant,t0,tf) 
            arguments
                prob (1,1) CollocationProblem;
                objfun (1,1) Objective;
                plant (1,1) Plant;
                t0 (1,1) Time;
                tf (1,1) Time;
            end
            obj.Problem = prob; 
            obj.Objective = objfun;
            obj.Plant = plant; 
            obj.InitialTime = t0;
            obj.FinalTime = tf;
            obj.setTime(); 
        end
        function varargout = solve(obj,solver)
            arguments
                obj (1,1) DirectCollocation;
                solver (1,1) string = "ipopt";
            end
            obj.Problem.Problem.solver(char(solver));
            obj.cost();
            obj.defect();
            sol = obj.Problem.Problem.solve();
            obj.setFromSol(sol); 
            obj.setTime();
            if nargout > 0
                varargout{1} = sol;
            end
        end
        function [t,x,u] = interpolate(obj)
            t = obj.interpolateTime();
            x = zeros(obj.Plant.NumStates,numel(t));
            u = zeros(obj.Plant.NumControls,numel(t));
            for k = 1:obj.Problem.NumNodes - 1
                x(:,(k - 1)*obj.ns + 1:k*obj.ns) = obj.interpolateState(k);
                u(:,(k - 1)*obj.ns + 1:k*obj.ns) = obj.interpolateControl(k);
            end
        end
        function fig = plotState(obj,rows,cols)
            fig = figure();
            tiledlayout(rows,cols,"Parent",fig);
            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;
            [t,x,~] = obj.interpolate();
            xn = obj.Plant.States.getValues(); 
            names = obj.Plant.States.getNames(); 
            units = obj.Plant.States.getUnits(); 
            for i = 1:size(x,1)
                nexttile();
                hold("on");
                plot(t,x(i,:),"k");
                scatter(obj.Time,xn(i,:),20,'k',"filled");
                hold("off");
                box(gca,"on");
                xlim([t0,tf]);
                title(names(i));
                xlabel(obj.InitialTime.Unit.toString());
                ylabel(units(i));
            end
        end
        function fig = plotControl(obj,rows,cols)
            fig = figure();
            tiledlayout(rows,cols,"Parent",fig);
            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;
            [t,~,u] = obj.interpolate();
            un = obj.Plant.Controls.getValues();
            names = obj.Plant.Controls.getNames();
            units = obj.Plant.Controls.getUnits();
            for i = 1:size(u,1)
                nexttile();
                hold("on");
                plot(t,u(i,:),"k");
                scatter(obj.Time,un(i,:),20,'k',"filled");
                hold("off");
                box(gca,"on");
                xlim([t0,tf]);
                title(names(i));
                xlabel(obj.InitialTime.Unit.toString());
                ylabel(units(i));
            end
        end
    end
    methods (Access = private) 
        function setTime(obj)
            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;
            obj.Time = linspace(t0,tf,obj.Problem.NumNodes);
        end
        function setStates(obj,sol)
            x = sol.value(obj.Plant.States.Variable);
            obj.Plant.States.set(x);
        end 
        function setControls(obj,sol)
            F = sol.value(obj.Plant.Controls.Variable);
            obj.Plant.Controls.set(F);
        end
        function setInitialTime(obj,sol)
            if isequal(class(obj.InitialTime),"FreeTime")
                T0 = sol.value(obj.InitialTime.get());
                obj.InitialTime.set(sol.value(T0));
            end
        end
        function setFinalTime(obj,sol)
            if isequal(class(obj.FinalTime),"FreeTime")
                TF = sol.value(obj.FinalTime.get());
                obj.FinalTime.set(sol.value(TF));
            end
        end
        function setFromSol(obj,sol)
            obj.setStates(sol);
            obj.setControls(sol);
            obj.setInitialTime(sol);
            obj.setFinalTime(sol); 
        end
    end
    methods (Access = protected) 
        function [t0,tf] = getTimes(obj)
            t0 = obj.InitialTime.get();
            tf = obj.FinalTime.get();
        end
        function t = interpolateTime(obj)
            t = zeros(1,(obj.Problem.NumNodes - 1)*obj.ns);
            for k = 1:obj.Problem.NumNodes - 1
                t0 = obj.Time(k);
                tf = obj.Time(k + 1);
                t((k - 1)*obj.ns + 1:k*obj.ns) = linspace(t0,tf,obj.ns);
            end 
        end
    end
    methods (Access = protected, Abstract)
        cost(obj);
        defect(obj);
        interpolateState(obj,k);
        interpolateControl(obj,k);
    end
end