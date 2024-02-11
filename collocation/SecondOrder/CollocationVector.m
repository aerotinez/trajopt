classdef CollocationVector < handle
    properties (GetAccess = public, SetAccess = private)
        Problem;
        Variables;
    end
    properties (Access = private)
        X;
    end
    methods (Access = public)
        function obj = CollocationVector(x)
            arguments
                x (:,1) CollocationVariable;
            end
            obj.Problem = x(1).Problem;
            obj.Variables = x;
            obj.initialize();
        end
        function x = getValues(obj)
            x = reshape([obj.Variables.Value].',numel(obj.Variables),[]);
        end
        function x = getVariables(obj)
            x = obj.X;
        end
        function set(obj,x)
            for i = 1:numel(obj.Variables)
                obj.Variables(i).set(x(i,:));
            end
        end
    end
    methods (Access = private)
        function initialize(obj)
            obj.X = cell(1,obj.Problem.NumNodes);
            x0 = reshape([obj.Variables.Value].',numel(obj.Variables),[]);
            for k = 1:obj.Problem.NumNodes
                obj.X{k} = obj.Problem.Problem.variable(numel(obj.Variables));
                obj.Problem.Problem.set_initial(obj.X{k},x0(:,k));
            end
        end
    end
end