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
        function prog = transcribe(obj,mesh,state,control,initial_time,final_time)
            arguments
                obj ocp;
                mesh (1,1) nlpmesh;
                state double;
                control double;
                initial_time double {mustBeScalarOrEmpty} = double.empty(0,1);
                final_time double {mustBeScalarOrEmpty} = double.empty(0,1);
            end
            x0 = state;
            u0 = control;
            ist0free = obj.isInitialTimeFree(); 
            istffree = obj.isFinalTimeFree();
            [t0,tf] = obj.getInitialAndFinalTimes(initial_time,final_time);
            vars = nlpvars(x0,u0,t0,ist0free,tf,istffree); 
            [Aeq,beq] = obj.boundaryConstraints(mesh.NumPoints - 1);
            lb = obj.lowerBounds(mesh.NumPoints - 1);
            ub = obj.upperBounds(mesh.NumPoints - 1);
            fcost = obj.CostFunction;
            fcon = obj.Constraints;
            prog = nlp(mesh,vars,fcost,fcon,Aeq,beq,lb,ub); 
        end
        function disp(obj)
            consoletitle("Optimal Control Problem",'=');
            disp(obj.CostFunction);
            disp(obj.Constraints);
        end
    end
    methods (Access = private)
        function val = isInitialTimeFree(obj)
            val = isempty(obj.Variables.Variable.Initial);
        end
        function val = isFinalTimeFree(obj)
            val = isempty(obj.Variables.Variable.Final);
        end
        function [t0,tf] = getInitialAndFinalTimes(obj,initial_time,final_time)
            t0 = initial_time;
            if ~obj.isInitialTimeFree()
                t0 = obj.Variables.Variable.Initial;
            end
            tf = final_time;
            if ~obj.isFinalTimeFree()
                tf = obj.Variables.Variable.Final;
            end
        end
        function [Aeq,beq] = boundaryConstraints(obj,N)
            Aeq = [];
            beq = [];
            nx = obj.Variables.NumStates;
            nu = obj.Variables.NumControls;
            x0 = [obj.Variables.State.Initial].';
            xf = [obj.Variables.State.Final].';
            if ~isempty(x0)
                Aeq = [eye(nx),zeros(nx,nu),zeros(nx,(nx + nu)*(N - 1))];
                beq = x0;
            end
            if ~isempty(xf)
                Aeq = [Aeq;zeros(nx,(nx + nu)*(N - 1)),eye(nx),zeros(nx,nu)];
                beq = [beq;xf];
            end
            if obj.isFinalTimeFree()
                Aeq = [zeros(size(Aeq,1),1),Aeq];
            end
            if obj.isInitialTimeFree()
                Aeq = [zeros(size(Aeq,1),1),Aeq];
            end
        end
        function lb = lowerBounds(obj,N)
            y = [obj.Variables.State;obj.Variables.Control];
            lb = reshape(repmat([y.LowerBound].',[1,N]),[],1);
            if obj.isFinalTimeFree()
                lb = [
                    obj.Variables.Variable.LowerBound;
                    lb
                    ];
            end
            if obj.isInitialTimeFree()
                lb = [
                    obj.Variables.Variable.LowerBound;
                    lb
                    ];
            end
        end
        function ub = upperBounds(obj,N)
            y = [obj.Variables.State;obj.Variables.Control];
            ub = reshape(repmat([y.UpperBound].',[1,N]),[],1);
            if obj.isFinalTimeFree()
                ub = [
                    obj.Variables.Variable.UpperBound
                    ub
                    ];
            end
            if obj.isInitialTimeFree()
                ub = [
                    obj.Variables.Variable.UpperBound
                    ub
                    ];
            end
        end
    end 
end