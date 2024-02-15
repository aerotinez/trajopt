classdef FreeTime < Time
    properties (GetAccess = public, SetAccess = private)
        Problem;
        LowerBound;
        UpperBound;
    end
    properties (Access = private)
        Variable;
    end
    methods (Access = public)
        function obj = FreeTime(problem,name,unit,value,lower,upper)
            arguments
                problem (1,1) CollocationProblem;
                name;
                unit;
                value;
                lower (1,1) double = -Inf;
                upper (1,1) double = Inf;
            end
            obj@Time(name,unit,value);
            obj.initialize(problem,lower,upper);
        end
        function time = get(obj)
            time = obj.Variable;
        end
        function set(obj,time)
            obj.Value = time;
            obj.Problem.Problem.set_initial(obj.Variable,obj.Value);
        end
    end
    methods (Access = private)
        function initialize(obj,problem,lower,upper)
            obj.Problem = problem; 
            obj.Variable = obj.Problem.Problem.variable(1);
            obj.Problem.Problem.set_initial(obj.Variable,obj.Value);
            obj.setLowerBound(lower);
            obj.setUpperBound(upper);
        end
        function setBound(obj,fun,bound)
            arguments
                obj (1,1) FreeTime;
                fun (1,1) function_handle;
                bound (1,1) double;
            end
            if ~isinf(bound)
                obj.Problem.Problem.subject_to(fun(obj.Variable,bound));
            end
        end
        function setLowerBound(obj,bound)
            obj.LowerBound = bound;
            obj.setBound(@ge,bound);
        end
        function setUpperBound(obj,bound)
            obj.UpperBound = bound;
            obj.setBound(@le,bound);
        end
    end
end