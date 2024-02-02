classdef nlpvars < handle
    properties (Access = public)
        InitialTime;
        FinalTime;
        State;
        Control; 
        NumStates;
        NumControls;
        NumPoints;
        VariableName;
        StateNames;
        ControlNames;
        StateUnitName;
        ControlUnitName;
        VariableUnit;
        StateUnits;
        ControlUnits;
        FreeInitialTime (1,1) logical = false;
        FreeFinalTime (1,1) logical = false;
    end 
    methods (Access = public) 
        function z = get(obj)
            z = reshape([obj.State;obj.Control],[],1);
            if obj.FreeFinalTime
                z = [obj.FinalTime;z];
            end
            if obj.FreeInitialTime
                z = [obj.InitialTime;z];
            end
        end
        function set(obj,z)
            arguments
                obj (1,1) nlpvars
                z (:,1) double
            end
            [t0,tf,x,u] = obj.unpack(z);
            obj.InitialTime = t0;
            obj.FinalTime = tf;
            obj.State = x;
            obj.Control = u;
            obj.NumPoints = size(x,2);
        end
        function [t0,tf,x,u] = unpack(obj,z)
            arguments
                obj (1,1) nlpvars
                z (:,1) double
            end
            [t0,tf,y] = obj.unpackTimes(z);
            x = y(1:obj.NumStates,:);
            u = y(obj.NumStates + 1:end,:);
        end
        function fig = plot(obj,mesh,rows,cols)
            arguments
                obj (1,1) nlpvars;
                mesh (1,1) nlpmesh;
                rows (1,1) double;
                cols (1,1) double;
            end
            fig = figure();
            tiledlayout(fig,rows,cols);
            m = mesh.Mesh;
            t0 = obj.InitialTime;
            tf = obj.FinalTime;
            t = [0,cumsum(diff(m).*(tf - t0)) + t0];
            y = [obj.State;obj.Control];
            titles = [obj.StateNames;obj.ControlNames];
            labels = [obj.StateUnitName;obj.ControlUnitName];
            units = [obj.StateUnits;obj.ControlUnits];
            for i = 1:(obj.NumStates + obj.NumControls)
                nexttile();
                scatter(t,y(i,:),20,"filled", ...
                    "MarkerFaceColor",'k', ...
                    "MarkerEdgeColor",'k');
                xlim([t0,tf]);
                box("on");
                title(titles(i));
                xlabel(strcat(obj.VariableName," (",obj.VariableUnit,")"));
                ylabel(strcat(labels(i)," (",units(i),")"));
            end
        end
    end
    methods (Access = private)
        function [t0,tf,y] = unpackTimes(obj,z)
            t0 = obj.InitialTime;
            tf = obj.FinalTime;
            y = z;
            if obj.FreeInitialTime && obj.FreeFinalTime
                t0 = z(1);
                tf = z(2);
                y = z(3:end);
            elseif obj.FreeInitialTime && ~obj.FreeFinalTime
                t0 = z(1);
                y = z(2:end);
            elseif ~obj.FreeInitialTime && obj.FreeFinalTime
                tf = z(1);
                y = z(2:end);
            end
            y = reshape(y,obj.NumStates + obj.NumControls,[]);
        end
    end
end