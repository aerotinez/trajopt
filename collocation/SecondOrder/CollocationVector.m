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
            obj.setBounds();
        end
        function x = getValues(obj)
            x = reshape([obj.Variables.Value].',numel(obj.Variables),[]);
        end
        function x = getVariables(obj)
            x = obj.X;
        end
        function setValues(obj,x)
            for i = 1:numel(obj.Variables)
                obj.Variables(i).setValue(x(i,:));
            end
        end
        function setInitial(obj)
            for i = 1:numel(obj.Variables)
                if ~isempty(obj.Variables(i).InitialValue)
                    x0 = obj.Variables(i).InitialValue;
                    obj.Problem.Problem.subject_to(obj.X{1}(i) == x0);
                end
            end
        end
        function setFinal(obj)
            for i = 1:numel(obj.Variables)
                if ~isempty(obj.Variables(i).FinalValue)
                    xf = obj.Variables(i).FinalValue;
                    obj.Problem.Problem.subject_to(obj.X{end}(i) == xf);
                end
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
        function setBounds(obj)
            for k = 1:obj.Problem.NumNodes
                for i = 1:numel(obj.Variables)
                    lb = obj.Variables(i).LowerBound;
                    ub = obj.Variables(i).UpperBound;
                    obj.Problem.Problem.subject_to((lb <= obj.X{k}(i)) <= ub); 
                end
            end
        end
    end
end