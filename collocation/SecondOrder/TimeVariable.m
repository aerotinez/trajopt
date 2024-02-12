classdef TimeVariable < handle
    properties (GetAccess = public, SetAccess = private)
        Problem;
        Name;
        Unit;
        Value;
        LowerBound;
        UpperBound;
    end
    properties (Access = private)
        Variable;
    end
    methods (Access = public)
        function obj = TimeVariable(varargin)
            if ~isequal(class(varargin{1}),'CollocationProblem')
                obj.initializeFixed(varargin{:});
                return;
            end
            obj.initializeFree(varargin{:}); 
        end
        function x = get(obj)
            if ~isempty(obj.Problem)
                x = obj.Variable;
                return;
            end
            x = obj.Value;
        end
        function set(obj,value)
            arguments
                obj (1,1);
                value (1,1) double;
            end
            obj.Value = value;
            if ~isempty(obj.Problem)
                obj.Problem.Problem.set_initial(obj.Variable,value);
            end
        end
    end
    methods (Access = private)
        function initializeFixed(obj,name,unit,value)
            arguments
                obj (1,1) TimeVariable;
                name (1,1) string;
                unit (1,1) Unit;
                value (1,1) double;
            end
            obj.Name = name;
            obj.Unit = unit;
            obj.set(value);
        end
        function initializeFree(obj,problem,name,unit,value,lower,upper)
            arguments
                obj (1,1) TimeVariable;
                problem (1,1) CollocationProblem;
                name (1,1) string;
                unit (1,1) Unit;
                value (1,1) double;
                lower (1,1) double = -inf;
                upper (1,1) double = inf;
            end
            obj.Problem = problem;
            obj.Name = name;
            obj.Unit = unit;
            obj.Variable = obj.Problem.Problem.variable(1);
            obj.set(value);
            obj.LowerBound = lower;
            obj.UpperBound = upper;
            obj.Problem.Problem.subject_to(obj.Variable >= lower);
            obj.Problem.Problem.subject_to(obj.Variable <= upper);
        end
    end 
end