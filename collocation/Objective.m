 classdef Objective < handle
    properties (GetAccess = public, SetAccess = private)
        Lagrange;
        Mayer;
    end
    properties (Access = private)
        NumStates;
        NumControls;
        NumParameters;
    end
    methods (Access = public)
        function obj = Objective(plant,lagrange,mayer)
            arguments
                plant (1,1) Plant;
                lagrange (1,1) function_handle = @(x,u,p) 0;
                mayer (1,1) function_handle = @(x0,t0,xf,tf) 0;
            end
            obj.NumStates = plant.NumStates;
            obj.NumControls = plant.NumControls;
            obj.NumParameters = plant.NumParameters;
            obj.Lagrange = obj.setLagrange(lagrange);
            obj.Mayer = obj.setMayer(mayer);
        end
    end
    methods (Access = private)
        function FL = setLagrange(obj,L)
            x = casadi.MX.sym('x',obj.NumStates);
            u = casadi.MX.sym('u',obj.NumControls);
            p = casadi.MX.sym('p',obj.NumParameters);
            vars = {x,u,p};
            inputs ={'x','u','p'};
            outputs = {'JL'};
            FL = casadi.Function('L',vars,{L(x,u,p)},inputs,outputs);
        end
        function FM = setMayer(obj,M)
            x0 = casadi.MX.sym('x0',obj.NumStates);
            t0 = casadi.MX.sym('t0',1);
            xf = casadi.MX.sym('xf',obj.NumStates);
            tf = casadi.MX.sym('tf',1);
            vars = {x0,t0,xf,tf};
            inputs ={'x0','t0','xf','tf'};
            outputs = {'JM'};
            FM = casadi.Function('M',vars,{M(x0,t0,xf,tf)},inputs,outputs);
        end
    end
end