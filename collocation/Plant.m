classdef Plant < handle
    properties (GetAccess = public, SetAccess = private)
        Problem;
        States;
        Controls;
        Parameters;
        Dynamics;
    end
    properties (GetAccess = public, SetAccess = private)
        NumStates;
        NumControls;
        NumParameters;
    end
    properties (Access = private)
        X;
        U;
        P;
    end
    methods (Access = public)
        function obj = Plant(prob,x,u,p,f)
            arguments
                prob (1,1) CollocationProblem;
                x (1,1) StateVector;
                u (1,1) StateVector;
                p double;
                f (1,1) function_handle;
            end
            obj.Problem = prob;
            obj.States = x;
            obj.Controls = u;
            obj.Parameters = obj.validateParameters(p);
            obj.setDimensions();
            obj.initializeInputs();
            obj.Dynamics = obj.setDynamics(f); 
        end
    end
    methods (Access = private)
        function p_out = validateParameters(obj,p)
            if size(p,2) == 1
                p = repmat(p,1,obj.Problem.NumNodes);
            end
            if size(p,2) ~= obj.Problem.NumNodes
                msg = "P must have as many columns as there are nodes.";
                error(msg);
            end
            p_out = p;
        end
        function setDimensions(obj)
            obj.NumStates = numel(obj.States.States);
            obj.NumControls = numel(obj.Controls.States);
            obj.NumParameters = size(obj.Parameters,1);
        end
        function initializeInputs(obj)
            obj.X = casadi.MX.sym('x',obj.NumStates);
            obj.U = casadi.MX.sym('u',obj.NumControls);
            obj.P = casadi.MX.sym('p',obj.NumParameters);
        end 
        function Fd = setDynamics(obj,fd)
            vars = {obj.X,obj.U,obj.P};
            f = fd(obj.X,obj.U,obj.P);
            inputs = {'x','u','p'};
            outputs = {'xd'};
            Fd = casadi.Function('Fd',vars,{f},inputs,outputs);
        end
    end
end