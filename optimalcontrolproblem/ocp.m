classdef ocp
    properties (GetAccess = public, SetAccess = private)
        Variables;
        CostFunction;
        Constraints;
    end
    methods (Access = public)
        function obj = ocp(variables,cost,constraints)
            arguments
                variables ocpvars;
                cost ocpcost;
                constraints ocpcon;
            end
            obj.Variables = variables;
            obj.CostFunction = cost;
            obj.Constraints = constraints;
        end 
        function disp(obj)
            consoletitle("Optimal Control Problem",'=');
            disp(obj.CostFunction);
            disp(obj.Constraints);
        end
    end 
end