classdef Plant < handle
    properties (GetAccess = public, SetAccess = private)
        Problem;
        Coordinates;
        Speeds;
        Controls;
        Parameters;
        Kinematics;
        KinematicRates;
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
        U;
        Ud;
        F;
        P;
    end 
    methods (Access = public)
        function obj = Plant(prob,q,u,F,p,fk,fkd,fd)
            arguments
                prob (1,1) CollocationProblem;
                q (1,1) CollocationVector;
                u (1,1) CollocationVector;
                F (1,1) CollocationVector;
                p double;
                fk (1,1) function_handle;
                fkd (1,1) function_handle;
                fd (1,1) function_handle;
            end
            obj.Problem = prob;
            obj.Coordinates = q;
            obj.NumCoordinates = numel(obj.Coordinates.Variables);
            obj.Speeds = u;
            obj.NumSpeeds = numel(obj.Speeds.Variables);
            obj.Controls = F;
            obj.NumControls = numel(obj.Controls.Variables);
            obj.Parameters = obj.validateParameters(p);
            obj.NumParameters = size(p,1);
            obj.Q = casadi.MX.sym('q',obj.NumCoordinates);
            obj.U = casadi.MX.sym('u',obj.NumSpeeds);
            obj.Ud = casadi.MX.sym('ud',obj.NumSpeeds);
            obj.F = casadi.MX.sym('F',obj.NumControls);
            obj.P = casadi.MX.sym('p',obj.NumParameters);
            obj.Kinematics = obj.setKinematics(fk);
            obj.KinematicRates = obj.setKinematicRates(fkd);
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
        function Fk = setKinematics(obj,fk)
            vars = {obj.Q,obj.U,obj.P};
            f = fk(obj.Q,obj.U,obj.P);
            inputs = {'q','u','p'};
            outputs = {'q_dot'};
            Fk = casadi.Function('Fk',vars,{f},inputs,outputs);
        end
        function Fkd = setKinematicRates(obj,fkd)
            vars = {obj.Q,obj.U,obj.Ud,obj.P};
            f = fkd(obj.Q,obj.U,obj.Ud,obj.P);
            inputs = {'q','u','ud','p'};
            outputs = {'q_dot_dot'};
            Fkd = casadi.Function('Fkd',vars,{f},inputs,outputs);
        end
        function Fd = setDynamics(obj,fd)
            vars = {obj.Q,obj.U,obj.F,obj.P};
            f = fd(obj.Q,obj.U,obj.F,obj.P);
            inputs = {'q','u','F','p'};
            outputs = {'q_dot_dot'};
            Fd = casadi.Function('Fd',vars,{f},inputs,outputs);
        end
    end
end