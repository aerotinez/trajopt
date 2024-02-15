classdef Plant < handle
    properties (GetAccess = public, SetAccess = private)
        Problem;
        Coordinates;
        Speeds;
        Controls;
        Parameters;
        RatesToSpeeds;
        Kinematics; 
        Dynamics;
    end
    properties (GetAccess = public, SetAccess = private)
        NumCoordinates;
        NumSpeeds;
        NumControls;
        NumParameters;
    end
    properties (Access = private)
        Q;
        Qd;
        U;
        F;
        P;
    end
    methods (Access = public)
        function obj = Plant(prob,q,u,F,p,fr,fk,fd)
            arguments
                prob (1,1) CollocationProblem;
                q (1,1) StateVector;
                u (1,1) StateVector;
                F (1,1) StateVector;
                p double;
                fr (1,1) function_handle;
                fk (1,1) function_handle; 
                fd (1,1) function_handle;
            end
            obj.Problem = prob;
            obj.Coordinates = q;
            obj.Speeds = u;
            obj.Controls = F;
            obj.Parameters = obj.validateParameters(p);
            obj.setDimensions();
            obj.initializeInputs();
            obj.RatesToSpeeds = obj.setRatesToSpeeds(fr);
            obj.Kinematics = obj.setKinematics(fk); 
            obj.Dynamics = obj.setDynamics(fd); 
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
            obj.NumCoordinates = numel(obj.Coordinates.States);
            obj.NumSpeeds = numel(obj.Speeds.States);
            obj.NumControls = numel(obj.Controls.States);
            obj.NumParameters = size(obj.Parameters,1);
        end
        function initializeInputs(obj)
            obj.Q = casadi.MX.sym('q',obj.NumCoordinates);
            obj.Qd = casadi.MX.sym('q_dot',obj.NumCoordinates);
            obj.U = casadi.MX.sym('u',obj.NumSpeeds);
            obj.F = casadi.MX.sym('F',obj.NumControls);
            obj.P = casadi.MX.sym('p',obj.NumParameters);
        end
        function Fr = setRatesToSpeeds(obj,fr)
            vars = {obj.Q,obj.Qd,obj.P};
            f = fr(obj.Q,obj.Qd,obj.P);
            inputs = {'q','q_dot','p'};
            outputs = {'u'};
            Fr = casadi.Function('Fr',vars,{f},inputs,outputs);
        end
        function Fk = setKinematics(obj,fk)
            vars = {obj.Q,obj.U,obj.P};
            f = fk(obj.Q,obj.U,obj.P);
            inputs = {'q','u','p'};
            outputs = {'q_dot'};
            Fk = casadi.Function('Fk',vars,{f},inputs,outputs);
        end
        function Fd = setDynamics(obj,fd)
            vars = {obj.Q,obj.U,obj.F,obj.P};
            f = fd(obj.Q,obj.U,obj.F,obj.P);
            inputs = {'q','u','F','p'};
            outputs = {'q_ddot'};
            Fd = casadi.Function('Fd',vars,{f},inputs,outputs);
        end
    end
end