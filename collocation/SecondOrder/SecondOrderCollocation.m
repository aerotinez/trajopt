classdef SecondOrderCollocation < handle
    properties (GetAccess = public, SetAccess = protected)
        Problem;
        State;
        Objective;
        Plant;
        InitialTime;
        FinalTime;
        Time;
    end 
    properties (Access = protected)
        Q;
        U;
        F;
        P;
        X;
        ns = 100; 
    end
    methods (Access = public)
        function obj = SecondOrderCollocation(prob,objfun,plant,t0,tf) 
            arguments
                prob (1,1) CollocationProblem;
                objfun (1,1) CollocationObjective;
                plant (1,1) Plant;
                t0 (1,1) TimeVariable;
                tf (1,1) TimeVariable;
            end
            obj.Problem = prob;
            obj.State = [
                plant.Coordinates.Variables;
                plant.Speeds.Variables
                ];
            obj.Objective = objfun;
            obj.Plant = plant;
            obj.InitialTime = t0;
            obj.FinalTime = tf;
            obj.Q = obj.Plant.Coordinates.getVariables();
            obj.U = obj.Plant.Speeds.getVariables();
            obj.F = obj.Plant.Controls.getVariables();
            obj.P = obj.Plant.Parameters;
            obj.X = cellfun(@(q,u)[q;u],obj.Q,obj.U,"uniform",0);
            obj.Time = linspace(t0.Value,tf.Value,obj.Problem.NumNodes);
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
 
            for i = 1:(numel(obj.State))
                nexttile();
                scatter(obj.Time,x(i,:),20,'k',"filled");
                box(gca,"on");
                xlim([t0,tf]);
                title(obj.State(i).Name);
                xlabel(obj.InitialTime.Unit.toString());
                ylabel(obj.State(i).Unit.toString());
            end
        end
        function fig = plotControlNodes(obj,rows,cols)
            fig = figure();
            tiledlayout(rows,cols,"Parent",fig);
            t0 = obj.InitialTime.Value;
            tf = obj.FinalTime.Value;
            u = obj.Plant.Controls.getValues();
            for i = 1:numel(obj.Plant.Controls.Variables)
                nexttile();
                scatter(obj.Time,u(i,:),20,'k',"filled");
                box(gca,"on");
                xlim([t0,tf]);
                title(obj.Plant.Controls.Variables(i).Name);
                xlabel(obj.InitialTime.Unit.toString());
                ylabel(obj.Plant.Controls.Variables(i).Unit.toString());
            end
        end
    end
    methods (Access = protected) 
        function [t0,tf] = getTimes(obj)
            t0 = obj.InitialTime.get();
            tf = obj.FinalTime.get();
        end
        function J = cost(obj)
            [t0,tf] = obj.getTimes();
            J = 0;
            f = @(X,F)obj.Objective.Lagrange(X,F);
            L = cellfun(f,obj.X,obj.F,"uniform",0); 
            q = (tf - t0).*[L{:}].';
            dT = diff(obj.Problem.Mesh);
            b = (1/2).*sum([dT,0;0,dT],1);
            J = J + b*q;
            M = obj.Objective.Mayer(t0,obj.X{1},tf,obj.X{end});
            J = J + M; 
        end
    end
    methods (Access = protected, Abstract)
        defect(obj,k);
    end
end