classdef DirectCollocation < handle
    properties (GetAccess = public, SetAccess = protected)
        Problem;
        Objective;
        Plant;
        InitialTime;
        FinalTime;
        Time;
        ns = 100;
        StateRegularizationWeights;
        ControlRegularizationWeights;
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
        function fig = plotState(obj,rows,cols)
            fig = figure();
            tiledlayout(rows,cols,"Parent",fig);
            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;
            [t,x,~] = obj.interpolate();
            [tr,xr] = obj.simulatePlant();
            xn = obj.Plant.States.getValues(); 
            names = obj.Plant.States.getNames(); 
            units = obj.Plant.States.getUnits(); 
            for i = 1:size(x,1)
                nexttile();
                hold("on");
                col_points = scatter(obj.Time,xn(i,:),20,'k', ...
                    "LineWidth",1.5, ...
                    "MarkerFaceColor",'w');
                plot(t,x(i,:),":k","LineWidth",1.5);
                plot(tr,xr(i,:),"LineWidth",1.5,"Color","#0072BD");
                hold("off");
                uistack(col_points,"top");
                box(gca,"on");
                xlim([t0,tf]);
                title(names(i));
                xlabel(obj.InitialTime.Unit.toString());
                ylabel(units(i));
            end
            leg = legend("Interpolation","Simulation","Collocation Points");
            leg.Orientation = 'horizontal';
            leg.Layout.Tile = 'South';
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
    end
    methods (Access = protected, Abstract)
        cost(obj);
        defect(obj);
        setTime(obj); 
    end
    methods (Access = public, Abstract)
        interpolateTime(obj);
        interpolateState(obj);
        interpolateControl(obj);
        interpolate(obj);
        simulatePlant(obj);
    end
end