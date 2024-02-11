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
                value (1,:) double;
                initial (1,:) double {mustBeScalarOrEmpty} = double.empty(1,0);
                final (1,:) double {mustBeScalarOrEmpty} = double.empty(1,0);
                lower (1,1) double = -inf;
                upper (1,1) double = inf;
            end
            obj.Problem = problem;
            obj.Name = name;
            obj.Unit = unit;
            obj.set(value);
            obj.InitialValue = initial;
            obj.FinalValue = final;
            obj.LowerBound = lower;
            obj.UpperBound = upper;
        end 
        function set(obj,value)
            obj.validateNodes(value);
            obj.Value = value; 
        end
    end
    methods (Access = private)
        function validateNodes(obj,x)
            if numel(x) ~= obj.Problem.NumNodes
                msg = "X must have as many columns as there are nodes.";
                error(msg);
            end
        end 
    end
end