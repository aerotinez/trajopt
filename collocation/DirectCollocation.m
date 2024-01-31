classdef DirectCollocation < handle
    properties (GetAccess = public, SetAccess = private)
        Mesh (1,:) double;
        MeshSize (1,1) double;
        InitialGuess (:,1) double;
    end
    properties (Access = private) 
        InitialTime;
        FinalTime;
        IsInitialTimeFree;
        IsFinalTimeFree;
        NumStates;
        NumControls;
        InitialState;
        FinalState;
        LowerBounds;
        UpperBounds;
        Lagrange function_handle;
        Mayer function_handle;
        Defect function_handle;
    end
    methods (Access = public)
        function obj = DirectCollocation(method,ocp,mesh_size)
            arguments
                method function_handle;
                ocp OptimalControlProblem;
                mesh_size (1,1) double = 20;
            end
            obj.Lagrange = ocp.CostFunction.Terminal;
            obj.Mayer = ocp.CostFunction.Running;
            f = ocp.DynamicConstraints; 
            obj.Defect = @(x0,u0,xf,uf,h)method(f,x0,u0,xf,uf,h);
            obj.MeshSize = mesh_size;
            obj.Mesh = linspace(0,1,obj.MeshSize);
            obj.NumStates = ocp.Variables.NumStates;
            obj.NumControls = ocp.Variables.NumControls;
            obj.IsInitialTimeFree = isequal(class(ocp.InitialTime),"sym");
            obj.IsFinalTimeFree = isequal(class(ocp.FinalTime),"sym"); 
            if ~obj.IsInitialTimeFree
                obj.InitialTime = ocp.InitialTime;
            end
            if ~obj.IsFinalTimeFree
                obj.FinalTime = ocp.FinalTime;
            end
            if ~class(ocp.InitialState,"sym")
                obj.InitialState = ocp.InitialState;
            end
            if ~class(ocp.FinalState,"sym")
                obj.FinalState = ocp.FinalState;
            end

            lb = [
                ocp.Variables.StateLowerBounds;
                ocp.Variables.ControlLowerBounds
                ];

            ub = [
                ocp.Variables.UpperBounds;
                ocp.Variables.ControlUpperBounds
                ];

            obj.LowerBounds = repmat(lb,[obj.MeshSize,1]);
            obj.UpperBounds = repmat(ub,[obj.MeshSize,1]);

            if IsFinalTimeFree
                obj.LowerBounds = [
                    obj.LowerBounds;
                    ocp.Variables.ParameterLowerBound
                    ];

                obj.UpperBounds = [
                    obj.UpperBounds;
                    ocp.Variables.ParameterUpperBound
                    ];
            end

            if IsInitialTimeFree
                obj.LowerBounds = [
                    ocp.Variables.ParameterLowerBound;
                    obj.LowerBounds
                    ];

                obj.UpperBounds = [
                    ocp.Variables.ParameterUpperBound;
                    obj.UpperBounds
                    ];
            end
        end
        function initialGuess(obj,states,controls,initial_time,final_time)
            arguments
                obj (1,1) DirectCollocation;
                states (:,:) double;
                controls (:,:) double;
                initial_time (1,1) double = 0;
                final_time (1,1) double = 1;
            end
            obj.InitialGuess = reshape([states;controls],[],1);
            if obj.IsFinalTimeFree
                obj.InitialGuess = [
                    final_time;
                    obj.InitialGuess
                    ];
            end
            if obj.IsInitialTimeFree
                obj.InitialGuess = [
                    initial_time;
                    obj.InitialGuess
                    ];
            end
        end
        function z = optimize(obj)
            f = @obj.objective;
            z0 = obj.InitialGuess;
            A = [];
            b = [];
            [Aeq,beq] = obj.boundaryConstraints();
            lb = obj.LowerBounds;
            ub = obj.UpperBounds;
            nonlcon = @obj.nonlinearConstraints;
            z = fmincon(f,z0,A,b,Aeq,beq,lb,ub,nonlcon);
        end
    end
    methods (Access = private) 
        function t0 = unpackInitialTime(obj,z)
            t0 = obj.InitialTime;
            if obj.IsInitialTimeFree
                t0 = z(1);
            end
        end
        function tf = unpackFinalTime(obj,z)
            tf = obj.FinalTime;
            if obj.IsInitialTimeFree && obj.IsFinalTimeFree
                tf = z(2);
                return
            end
            if obj.IsFinalTimeFree && ~obj.IsInitialTimeFree
                tf = z(1);
            end
        end
        function y = unpackDefects(obj,z)
            N = obj.MeshSize;
            nx = obj.NumStates;
            nu = obj.NumControls;
            y = reshape(z(end - (nx + nu)*N + 1:end),[],N);
        end
        function x = unpackStates(obj,z)
            y = obj.unpackDefects(z);
            x = y(1:obj.NumStates,:);
        end
        function u = unpackControls(obj,z)
            y = obj.unpackDefects(z);
            u = y(obj.NumStates + 1:end,:);
        end
        function J = objective(obj,z)
            x0 = obj.InitialState;
            t0 = obj.unpackInitialTime(z);
            xf = obj.FinalState;
            tf = obj.unpackFinalTime(z);
            M = obj.Mayer(x0,t0,xf,tf);

            x = obj.unpackStates(z);
            u = obj.unpackControls(z);
            w = obj.Lagrange(x,u).';

            dm = diff(obj.Mesh);
            b = (1/2).*sum([dm(1:end - 1),0;0,dm(2:end)],2);
            h = diff(obj.Mesh).*(tf - t0);
            q = diag(h)*w;
            L = b*q;

            J = M + L;
        end
        function [Aeq,beq] = boundaryConstraints(obj)
            Aeq = [];
            beq = [];
            nx = obj.NumStates;
            nu = obj.NumControls;
            N = obj.MeshSize;
            if ~isempty(obj.InitialState)
                Aeq = [eye(nx),zeros(nx,nu),zeros(nx,(nx + nu)*(N - 1))];
                beq = obj.InitialState;
            end
            if ~isempty(obj.FinalState)
                Aeq = [Aeq;zeros(nx),zeros(nx,nu),zeros(nx,(nx + nu)*(N - 1))];
                beq = [beq;obj.FinalState];
            end
            if obj.IsInitialTimeFree
                Aeq = [zeros(size(Aeq,1),1),Aeq];
            end
            if obj.IsFinalTimeFree
                Aeq = [zeros(size(Aeq,1),1),Aeq];
            end
        end 
        function Ceq = defectConstraints(obj,z)
            t0 = obj.unpackInitialTime(z);
            tf = obj.unpackFinalTime(z);
            x = obj.unpackStates(z);
            u = obj.unpackControls(z);
            h = diff(obj.Mesh).*(tf - t0);
            x0 = x(:,1:end - 1);
            u0 = u(:,1:end - 1);
            xf = x(:,2:end);
            uf = u(:,2:end);
            Ceq = reshape(obj.Defect(x0,u0,xf,uf,h),[],1);
        end
        function [C,Ceq] = nonlinearConstraints(obj,z)
            C = [];
            Ceq = obj.defectConstraints(z);
        end
    end
end