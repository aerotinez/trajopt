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
            t = obj.Variables.Variable;
            obj.InitialTime = str2sym(sprintf(string(t) + "_%d",0));
            obj.InitialState = obj.Variables.States(obj.InitialTime);
            obj.FinalTime = str2sym(sprintf(string(t) + "_%s",'f'));
            obj.FinalState = obj.Variables.States(obj.FinalTime);
        end
        function disp(obj)
            disp("MINIMIZE:");

            t0 = obj.InitialTime;
            x0 = obj.InitialState;
            tf = obj.FinalTime;
            xf = obj.FinalState;
            M = obj.CostFunction.Terminal(x0,t0,xf,tf);
            if class(M) ~= "sym"
                M = 0;
            end

            t = obj.Variables.Variable;
            x = obj.Variables.States(t);
            u = obj.Variables.Controls(t);
            L = int(obj.CostFunction.Running(x,u),t,t0,tf,"Hold",true);
            disp(M + L);

            fprintf("SUBJECT TO:\n\n");

            disp("Dynamic constraints:");
            disp(diff(x,t) == obj.DynamicConstraints.Dynamics(x,u));

            disp("Path constraints:");
            if any(obj.PathConstraint(x,u))
                disp(obj.PathConstraint(x,u) <= 0);
            else
                fprintf("\n");
            end

            disp("Boundary constraints:");
            if any(obj.BoundaryConstraint(x0,t0,xf,tf))
                disp(obj.BoundaryConstraint(x0,t0,xf,tf) <= 0);
            else
                fprintf("\n");
            end

            disp("Parameter bounds:");
            tlb = obj.Variables.VariableLowerBound;
            tub = obj.Variables.VariableUpperBound;
            obj.displayParameterConstraints(t0,tf,tlb,tub);

            disp("State bounds:");
            xlb = obj.Variables.StateLowerBounds;
            xub = obj.Variables.StateUpperBounds;
            obj.displayBoundConstraints(x,xlb,xub);

            disp("Control bounds:");
            ulb = obj.Variables.ControlLowerBounds;
            uub = obj.Variables.ControlUpperBounds;
            obj.displayBoundConstraints(u,ulb,uub);
        end 
    end
    methods (Access = private)
        function displayParameterConstraints(~,t0,tf,tlb,tub)
            if ~isempty(tlb) && isempty(tub)
                disp(tf > (t0 >= tlb));
            elseif isempty(tlb) && ~isempty(tub)
                disp(t0 < (tf <= tub));
            elseif ~isempty(tlb) && ~isempty(tub)
                disp((tlb <= t0) < (tf <= tub));
            else
                fprintf("\n");
            end
        end
        function displayBoundConstraints(~,x,lb,ub)
            if ~isempty(lb) && isempty(ub)
                disp(x >= lb);
            elseif isempty(lb) && ~isempty(ub)
                disp(x <= ub);
            elseif ~isempty(lb) && ~isempty(ub)
                disp((lb <= x) <= ub);
            else
                fprintf("\n");
            end
        end
    end
end