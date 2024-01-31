classdef OptimalControlProblem < handle
    properties (GetAccess = public, SetAccess = private)
        Variables OptimizationVariables;
        CostFunction Cost;
        DynamicConstraints Plant;
        PathConstraint function_handle;
        BoundaryConstraint function_handle;
    end
    properties (Access = public)
        InitialTime;
        InitialState;
        FinalTime;
        FinalState; 
    end
    properties (Access = private)
    end
    methods (Access = public)
        function obj = OptimalControlProblem(variables,cost,plant,path,boundary)
            arguments
                variables OptimizationVariables;
                cost Cost;
                plant Plant;

                % Path constraint function prototype:
                %   h = path(x,u)
                %   x: state vector
                %   u: control vector
                path function_handle = @(x,u)0;

                % Boundary constraint function prototype:
                %   g = boundary(x0,t0,xf,tf)
                %   x0: initial state
                %   t0: initial time
                %   xf: final state
                %   tf: final time
                boundary function_handle = @(x0,t0,xf,tf)0;
            end
            obj.Variables = variables;
            obj.CostFunction = cost;
            obj.DynamicConstraints = plant;
            obj.PathConstraint = path;
            obj.BoundaryConstraint = boundary;
            t = obj.Variables.Parameter;
            obj.InitialTime = str2sym(sprintf(string(t) + "_%d",0));
            obj.InitialState = obj.Variables.States(obj.InitialTime);
            obj.FinalTime = str2sym(sprintf(string(t) + "_%s",'f'));
            obj.FinalState = obj.Variables.States(obj.FinalTime);
        end
        function disp(obj)
            disp("MINIMIZE:");
            dispObjective(obj);
            fprintf("SUBJECT TO:\n\n");
            dispDynamicConstraints(obj);
            dispPathConstraints(obj);
            dispBoundaryConstraints(obj);
            dispParameterBounds(obj);
            dispStateBounds(obj);
            dispControlBounds(obj);
        end 
    end
    methods (Access = private)
        function dispObjective(obj)
            t0 = obj.InitialTime;
            x0 = obj.InitialState;
            tf = obj.FinalTime;
            xf = obj.FinalState;
            M = obj.CostFunction.Terminal(x0,t0,xf,tf);
            if class(M) ~= "sym"
                M = 0;
            end

            t = obj.Variables.Parameter;
            x = obj.Variables.States(t);
            u = obj.Variables.Controls(t);
            L = int(obj.CostFunction.Running(x, u),t,t0,tf,"Hold",true);
            disp(M + L);
        end
        function dispDynamicConstraints(obj)
            disp("Dynamic constraints:");
            t = obj.Variables.Parameter;
            x = obj.Variables.States(t);
            u = obj.Variables.Controls(t);
            disp(diff(x, t) == obj.DynamicConstraints.Dynamics(x,u));
        end
        function dispPathConstraints(obj)
            t = obj.Variables.Parameter;
            x = obj.Variables.States(t);
            u = obj.Variables.Controls(t);
            if any(obj.PathConstraint(x,u))
                disp("Path constraints:");
                disp(obj.PathConstraint(x,u) <= 0);
            end
        end
        function dispBoundaryConstraints(obj)
            t0 = obj.InitialTime;
            tf = obj.FinalTime;
            x0 = obj.InitialState;
            xf = obj.FinalState;
            if any(obj.BoundaryConstraint(x0,t0,xf,tf))
                disp("Boundary constraints:");
                disp(obj.BoundaryConstraint(x0,t0,xf,tf) <= 0);
            end
        end
        function dispParameterBounds(obj)
            t0 = obj.InitialTime;
            tf = obj.FinalTime;
            tlb = obj.Variables.ParameterLowerBound;
            tub = obj.Variables.ParameterUpperBound;
            if ~all(isinf(tlb)) || ~all(isinf(tub)) 
                disp("Parameter bounds:");
                obj.displayParameterConstraints(t0,tf,tlb,tub);
            end
        end
        function dispStateBounds(obj)
            t = obj.Variables.Parameter;
            x = obj.Variables.States(t);
            xlb = obj.Variables.StateLowerBounds;
            xub = obj.Variables.StateUpperBounds;
            if ~all(isinf(xlb)) || ~all(isinf(xub)) 
                disp("State bounds:");
                obj.displayBoundConstraints(x,xlb,xub);
            end
        end
        function dispControlBounds(obj)
            t = obj.Variables.Parameter;
            u = obj.Variables.Controls(t);
            ulb = obj.Variables.ControlLowerBounds;
            uub = obj.Variables.ControlUpperBounds;
            if ~all(isinf(ulb)) || ~all(isinf(uub)) 
                disp("Control bounds:");
                obj.displayBoundConstraints(u,ulb,uub);
            end
        end
        function displayParameterConstraints(~,t0,tf,tlb,tub) 
            if ~all(isinf(tlb)) && all(isinf(tub)) 
                disp(tf > (t0 >= tlb));
            elseif all(isinf(tlb)) && ~all(isinf(tub)) 
                disp(t0 < (tf <= tub));
            elseif ~all(isinf(tlb)) && ~all(isinf(tub)) 
                disp((tlb <= t0) < (tf <= tub)); 
            end
        end
        function displayBoundConstraints(~,x,lb,ub)
            if ~all(isinf(lb)) && all(isinf(ub)) 
                disp(x >= lb);
            elseif all(isinf(lb)) && ~all(isinf(ub)) 
                disp(x <= ub);
            elseif ~all(isinf(lb)) && ~all(isinf(ub)) 
                disp((lb <= x) <= ub); 
            end
        end
    end
end