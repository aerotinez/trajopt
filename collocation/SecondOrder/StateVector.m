classdef StateVector < handle 
    properties (GetAccess = public, SetAccess = private)
        Problem;
        States;
        Variable;
    end
    methods (Access = public)
        function obj = StateVector(states)
            arguments
                states (:,1) State;
            end
            obj.Problem = states(1).Problem;
            obj.States = states;
            obj.initialize();
        end
        function values = getValues(obj)
            M = obj.Problem.NumNodes;
            values = reshape([obj.States.Value].',M,[]).';
        end
        function names = getNames(obj)
            names = [obj.States.Name].';
        end
        function units = getUnits(obj)
            units = arrayfun(@(x)x.Unit.toString(),obj.States);
        end
        function set(obj,values)
            arguments
                obj (1,1) StateVector;
                values (:,:) double {mustBeReal,mustBeFinite,mustBeNonNan};
            end
            if size(values,1) ~= numel(obj.States)
                msg = "VALUES must have as many rows as there are states.";
                error(msg);
            end 
            cellfun(@(x,v)x.set(v),num2cell(obj.States,2),num2cell(values,2));
            obj.Problem.Problem.set_initial(obj.Variable,values);
        end
    end 
    methods (Access = private)
        function initialize(obj)
            values = obj.getValues();
            initial = [obj.States.InitialValue].';
            final = [obj.States.FinalValue].';
            lower = [obj.States.LowerBound].';
            upper = [obj.States.UpperBound].';
            f = @CollocationVariableFactory;
            B = f(obj.Problem.Problem,values,initial,final,lower,upper);
            obj.Variable = B.create();
        end 
    end
end