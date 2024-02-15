classdef SecondOrderCollocation < handle
    properties (GetAccess = public, SetAccess = protected)
        Problem;
        Objective;
        Plant;
        InitialTime;
        FinalTime;
        Time;
    end  
    methods (Access = public)
        function obj = SecondOrderCollocation(prob,objfun,plant,t0,tf) 
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
            obj.defect();
        end
        function solve(obj,solver)
            arguments
                obj (1,1) SecondOrderCollocation;
                solver (1,1) string = "ipopt";
            end
            J = obj.cost();
            obj.Problem.Problem.minimize(J);
            obj.Problem.Problem.solver(char(solver));
            sol = obj.Problem.Problem.solve();
            obj.setFromSol(sol); 
            obj.setTime();  
        end
        function fig = plotStateNodes(obj,rows,cols)
            fig = figure();
            tiledlayout(rows,cols,"Parent",fig);

            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;

            x = [
                obj.Plant.Coordinates.getValues();
                obj.Plant.Speeds.getValues()
                ];

            names = [
                obj.Plant.Coordinates.getNames();
                obj.Plant.Speeds.getNames()
                ];

            units = [
                obj.Plant.Coordinates.getUnits();
                obj.Plant.Speeds.getUnits()
                ];
 
            for i = 1:size(x,1)
                nexttile();
                scatter(obj.Time,x(i,:),20,'k',"filled");
                box(gca,"on");
                xlim([t0,tf]);
                title(names(i));
                xlabel(obj.InitialTime.Unit.toString());
                ylabel(units(i));
            end
        end
        function fig = plotControlNodes(obj,rows,cols)
            fig = figure();
            tiledlayout(rows,cols,"Parent",fig);

            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;

            u = obj.Plant.Controls.getValues();

            names = obj.Plant.Controls.getNames();

            units = obj.Plant.Controls.getUnits();

            for i = 1:size(u,1)
                nexttile();
                scatter(obj.Time,u(i,:),20,'k',"filled");
                box(gca,"on");
                xlim([t0,tf]);
                title(names(i));
                xlabel(obj.InitialTime.Unit.toString());
                ylabel(units(i));
            end
        end
    end
    methods (Access = private)
        function J = cost(obj)
            J = 0;

            X = [
                obj.Plant.Coordinates.Variable;
                obj.Plant.Speeds.Variable
                ];
            
            F = obj.Plant.Controls.Variable;

            L = obj.Objective.Lagrange(X,F).';
            [t0,tf] = obj.getTimes();
            q = (tf - t0).*L;
            dT = diff(obj.Problem.Mesh);
            b = (1/2).*sum([dT,0;0,dT],1);
            J = J + b*q;

            M = obj.Objective.Mayer(X(:,1),t0,X(:,end),tf);
            J = J + M; 
        end 
        function setTime(obj)
            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;
            obj.Time = linspace(t0,tf,obj.Problem.NumNodes);
        end
        function setCoordinates(obj,sol)
            q = sol.value(obj.Plant.Coordinates.Variable);
            obj.Plant.Coordinates.set(q);
        end
        function setSpeeds(obj,sol)
            u = sol.value(obj.Plant.Speeds.Variable);
            obj.Plant.Speeds.set(u);
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
            obj.setCoordinates(sol);
            obj.setSpeeds(sol);
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
        defect(obj,k);
    end
end