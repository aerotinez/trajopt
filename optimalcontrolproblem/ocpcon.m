classdef ocpcon
    properties (GetAccess = public, SetAccess = private)
        Dynamics;
        Path; 
    end
    properties (Access = private)
        Vars;
    end
    methods (Access = public)
        function obj = ocpcon(vars,dynamics)
            arguments
                vars (1,1) ocpvars;
                dynamics (1,1) dyncon;
            end
            obj.Vars = vars;
            obj.Dynamics = dynamics;
        end
        function disp(obj)
            consoleborder();
            consoletitle("SUBJECT TO");
            consoleborder();
            disp(obj.Dynamics);
            obj.dispPathBounds(obj.Vars.State,'State path bounds');
            obj.dispPathBounds(obj.Vars.Control,'Control path bounds');
            consoleborder();
        end 
    end
    methods (Access = private)
        function ineq = pathBound(~,f,x,b) 
            if isinf(b)
                ineq = [];
                return;
            end
            ineq = f(x,b);
        end
        function ineq = pathLowerBound(obj,x,b)
            ineq = obj.pathBound(@(x,b)b <= x,x,b);
        end
        function ineq = pathUpperBound(obj,x,b)
            ineq = obj.pathBound(@(x,b)x <= b,x,b);
        end 
        function dispPathBounds(obj,z,msg) 
            x = arrayfun(@(z)z.sym(),z);
            lb = [z.LowerBound].';
            ub = [z.UpperBound].';
            if any(~isinf([lb;ub]))
                consoletitle(msg,'=');
                disp(cell2sym(arrayfun(@obj.pathLowerBound,x,lb,'uniform',0)));
                disp(cell2sym(arrayfun(@obj.pathUpperBound,x,ub,'uniform',0)));
            end 
        end 
    end 
end