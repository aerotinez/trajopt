classdef ocpcost
    properties (GetAccess = public, SetAccess = private)
        % Lagrange term (running cost)
        %   Function prototype:
        %       L = lagrange(x,u)
        %   where:
        %       x - state vector
        %       u - control vector
        %       t - time
        Lagrange;

        % Mayer term (initial and/or terminal cost)
        %   Function prototype:
        %       M = mayer(x0,t0,xf,tf)
        %   where:
        %       x0 - initial state  
        %       t0 - initial time
        %       xf - final state
        %       tf - final time
        Mayer;
    end
    properties (Access = private)
        Vars;
    end
    methods (Access = public)
        function obj = ocpcost(vars,lagrange,mayer)
            arguments
                vars (1,1) ocpvars;
                lagrange (1,1) function_handle;
                mayer (1,1) function_handle = @(x0,t0,xf,tf)0;
            end
            obj.Vars = vars;
            obj.Lagrange = lagrange;
            obj.Mayer = mayer;
        end
        function disp(obj)
            [t,x,u] = obj.Vars.sym();
            L = obj.Lagrange(x,u);
            x0 = obj.initialState();
            t0 = obj.lowerLimit();
            xf = obj.finalState();
            tf = obj.upperLimit();
            M = obj.Mayer(x0,t0,xf,tf);
            w = int(L,t,t0,tf);
            consoleborder();
            consoletitle("MINIMISE");
            consoleborder();
            disp(sym('J') == w + M);
        end
    end
    methods (Access = private)
        function lim = limit(obj,t,s)
            if ~isempty(t)
                lim = t;
                return 
            end
            lim = str2sym(sprintf("%s_%s",obj.Vars.Variable.Symbol,s));
        end
        function t0 = lowerLimit(obj)
            t0 = obj.limit(obj.Vars.Variable.Initial,'0');
        end
        function tf = upperLimit(obj)
            tf = obj.limit(obj.Vars.Variable.Final,'f');
        end
        function xb = boundaryState(obj,f,ti)
            xb = cell2mat(arrayfun(f,obj.Vars.State,"UniformOutput",false));
            if ~all(isempty(xb))
                return
            end
            t = obj.Vars.Variable.sym();
            x = arrayfun(@(x)x.sym(),obj.Vars.State);
            xb = subs(x,t,ti);
        end
        function x0 = initialState(obj)
            x0 = obj.boundaryState(@(x)x.Initial,obj.lowerLimit()); 
        end
        function xf = finalState(obj)
            xf = obj.boundaryState(@(x)x.Final,obj.upperLimit()); 
        end
    end 
end