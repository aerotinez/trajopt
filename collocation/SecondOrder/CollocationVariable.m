classdef CollocationVariable < handle
    properties (GetAccess = public, SetAccess = private)
        Problem;
        Name;
        Unit;
        Value;
        InitialValue;
        FinalValue;
        LowerBound;
        UpperBound;
    end
    properties (Access = private)
        Variables;
        NumNodes;
    end
    methods (Access = public)
        function obj = CollocationVariable( ...
            problem, ...
            name, ...
            unit, ...
            value, ...
            initial, ...
            final, ...
            lower, ...
            upper ...
            )
            arguments
                problem (1,1) CollocationProblem;
                name (1,1) string;
                unit (1,1) Unit;
                value double;
                initial (1,1) double = double.empty(1,1);
                final (1,1) double = double.empty(1,1);
                lower_bound (1,1) double = -inf;
                upper_bound (1,1) double = inf;
            end
            obj.Problem = problem;
            obj.Name = name;
            obj.Unit = unit;
            obj.initialize();
            obj.Value = value;
            obj.InitialValue = initial;
            obj.FinalValue = final;
            obj.LowerBound = lower;
            obj.UpperBound = upper;
            obj.NumNodes = obj.Problem.NumNodes;
        end
        function x = get(obj)
            x = obj.Variables;
        end
        function set(obj,value)
            obj.validateNodes(value);
            obj.Value = value;
            f = @(i,v)obj.Problem.Problem.set_initial(obj.Variable{i},v);
            arrayfun(f,1:obj.NumNodes,value);
        end
    end
    methods (Access = private)
        function validateNodes(obj,x)
            if numel(x) ~= obj.NumNodes
                msg = "X must have as many columns as there are nodes.";
                error(msg);
            end
        end
        function initialize(obj)
            f = @(i)obj.Problem.Problem.variable(1);
            obj.Variables = arrayfun(f,1:obj.NumNodes,"UniformOutput",false); 
        end
    end
end