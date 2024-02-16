classdef Plant < handle
    properties (GetAccess = public, SetAccess = private)
        Problem;
        States;
        Controls;
        Parameters;
        Dynamics;
        ODE;
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
            obj.ODE = obj.setODE(f); 
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
        function ode = setODE(obj,fd)
            dae = casadi.DaeBuilder('f');
            fx = @(x)dae.add_x(char(x.Name));
            x = arrayfun(fx,obj.States.States,'uniform',0);
            fu = @(u)dae.add_u(char(u.Name));
            u = arrayfun(fu,obj.Controls.States,'uniform',0);
            fp = @(i)dae.add_p(char("p_" + i));
            p = arrayfun(fp,(1:obj.NumParameters).','uniform',0);
            xd = fd([x{:}].',[u{:}].',[p{:}].');
            fxd = @(x,xd)dae.set_ode(char(x.Name),xd);
            arrayfun(fxd,obj.States.States,xd);
            ode = dae.create('f',{'x','u','p'},{'ode'});
        end
    end
end