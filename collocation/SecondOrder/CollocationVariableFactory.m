classdef CollocationVariableFactory
    properties (Access = private)
        Problem;
        NumStates;
        NumNodes;
        Value;
        InitialValue;
        FinalValue;
        LowerBound;
        UpperBound;
    end
    methods (Access = public)
        function obj = CollocationVariableFactory(problem,value,initial,final,lower,upper)
            arguments
                problem (1,1) casadi.Opti;
                value double {mustBeReal,mustBeFinite,mustBeNonNan};
                initial (:,1) double {mustBeReal} = nan(size(value,1),1);
                final (:,1) double {mustBeReal} = nan(size(value,1),1);
                lower (:,1) double {mustBeReal} = -inf(size(value,1),1);
                upper (:,1) double {mustBeReal} = inf(size(value,1),1);
            end
            obj.Problem = problem;
            obj.NumStates = size(value,1);
            obj.NumNodes = size(value,2);
            obj.Value = value;
            obj.InitialValue = initial;
            obj.FinalValue = final;
            obj.LowerBound = lower;
            obj.UpperBound = upper;
        end
        function variable = create(obj)
            variable = obj.Problem.variable(obj.NumStates,obj.NumNodes);
            obj.setLowerBounds(variable);
            obj.setUpperBounds(variable);
            obj.setInitialBound(variable,obj.InitialValue);
            obj.setFinalBound(variable,obj.FinalValue);
            obj.Problem.set_initial(variable,obj.Value);
        end
    end
    methods (Access = private)
        function out = transcribeBound(obj,bound)
            out = repmat(bound,[1,obj.NumNodes]);
        end 
        function setBound(obj,cond,variable,fun,bound)
            arguments
                obj (1,1) CollocationVariableFactory;
                cond (1,1) function_handle;
                variable (1,1) casadi.MX;
                fun (1,1) function_handle;
                bound (1,1) double;
            end
            if cond(bound)
                obj.Problem.subject_to(fun(variable,bound));
            end
        end
        function setPathBound(obj,variable,fun,bound)
            obj.setBound(@(b)~isinf(b),variable,fun,bound);
        end
        function setLowerBounds(obj,variable)
            lower = obj.transcribeBound(obj.LowerBound);
            f = @(x,b)obj.setPathBound(x,@ge,b);
            arrayfun(f,variable,lower);
        end
        function setUpperBounds(obj,variable)
            upper = obj.transcribeBound(obj.UpperBound);
            f = @(x,b)obj.setPathBound(x,@le,b);
            arrayfun(f,variable,upper);
        end
        function setEndBound(obj,variable,bound)
            obj.setBound(@(b)~isnan(b),variable,@eq,bound);
        end
        function setInitialBound(obj,variable,bound)
            arrayfun(@obj.setEndBound,variable(:,1),bound);
        end
        function setFinalBound(obj,variable,bound)
            arrayfun(@obj.setEndBound,variable(:,end),bound);
        end
    end
end