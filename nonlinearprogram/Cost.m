classdef Cost
    properties (GetAccess = public, SetAccess = private)
        Running;
        Terminal;
    end
    properties (Access = private)
        t;
        x;
        u;
        t0;
        x0;
        tf;
        xtf;
    end
    methods (Access = public)
        function obj = Cost(optimization_variables,running,terminal)
            arguments
                optimization_variables (1,1) OptimizationVariables;

                % Running cost function prototype:
                %   L = running(x,u)
                %   x: state vector
                %   u: control vector
                running (1,1) function_handle;

                % Terminal cost function prototype:
                %   M = terminal(x0,t0,xtf,tf)
                %   x0: initial state
                %   t0: initial time
                %   xtf: final state
                %   tf: final time
                terminal (1,1) function_handle = @(x0,t0,xtf,tf) 0;
            end
            obj.Running = running;
            obj.Terminal = terminal;
            obj.t = optimization_variables.Variable;
            obj.x = optimization_variables.States(obj.t);
            obj.u = optimization_variables.Controls(obj.t);
            obj.t0 = str2sym(sprintf(string(obj.t) + "_%d",0));
            obj.x0 = optimization_variables.States(obj.t0);
            obj.tf = str2sym(sprintf(string(obj.t) + "_%s",'f'));
            obj.xtf = optimization_variables.States(obj.tf); 
        end
        function disp(obj)
            disp("COST FUNCTION:");
            M = obj.Terminal(obj.x0,obj.t0,obj.xtf,obj.tf);
            L = int(obj.Running(obj.x,obj.u),obj.t,obj.t0,obj.tf);
            disp(M + L);
        end
    end
end