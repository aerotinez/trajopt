classdef CollocationConstraints 
    properties (GetAccess = public, SetAccess = private)
        Method;
        Vars;
        MeshSize;
        FinalTime;
    end
    properties (Access = private)
        f Plant;
        xtf (1,1) sym = sym("x_tf");
        confun function_handle;
        confunjac function_handle;
        confunjactf function_handle;
    end
    methods (Access = public)
        function obj = CollocationConstraints(plant,method,mesh_size,final_time)
            arguments
                plant (1,1) Plant;
                method (1,1) function_handle;
                mesh_size (1,1) double;
                final_time = [];
            end
            obj.f = plant;
            obj.Method = method;
            obj.MeshSize = mesh_size;
            obj.FinalTime = final_time;
            obj.Vars = obj.createVariables();
            obj.confun = obj.collocationFunction();
            obj.confunjac = obj.collocationJacobianFunction();
            obj.confunjactf = obj.collocationJacobianFunctionFinalTime(); 
        end
        function [C,Ceq,GC,GCeq] = nonlcon(obj,x)
            arguments
                obj (1,1) CollocationConstraints;
                x (:,1);
            end
            C = [];
            GC = [];
            if ~isempty(obj.FinalTime)
                Ceq = obj.constraint(x,obj.FinalTime);
                GCeq = obj.constraintJacobian(x,obj.FinalTime);
                return
            end
            Ceq = obj.constraint(x(1:end - 1),x(end));
            GCeq = obj.constraintJacobianMinimumTime(x(1:end - 1),x(end)).';
        end
    end
    methods (Access = private)
        function X = createVariables(obj)
            X = [
                sym("x_",[obj.f.NumStates,obj.MeshSize]);
                sym("u_",[obj.f.NumControls,obj.MeshSize]);
                ];
            f0 = @(i)str2sym(sprintf("x_%d_0",i));
            fN = @(i)str2sym(sprintf("x_%d_%d",i,obj.MeshSize + 1));
            X = [
                arrayfun(f0,(1:obj.f.NumStates).');
                reshape(X,[],1);
                arrayfun(fN,(1:obj.f.NumStates).');
                ];
            if isempty(obj.FinalTime)
                X = [
                    X;
                    obj.xtf;
                    ];
            end
        end
        function vars = funvars(obj)
            X = sym("x_",[obj.f.NumStates,2]);
            U = sym("u_",[obj.f.NumControls,2]);
            x0 = X(:,1);
            x1 = X(:,2);
            u0 = U(:,1);
            u1 = U(:,2);
            vars = [x0;u0;x1;u1];
        end
        function f = collocationFunction(obj)
            vars = obj.funvars();
            n = obj.f.NumStates + obj.f.NumControls;
            X = reshape(vars,n,[]);
            x0 = X(1:obj.f.NumStates,1);
            u0 = X(obj.f.NumStates + 1:end,1);
            x1 = X(1:obj.f.NumStates,2);
            u1 = X(obj.f.NumStates + 1:end,2);
            dt = obj.xtf/obj.MeshSize;
            fun = obj.Method(obj.f.Dynamics,x0,u0,x1,u1,dt);
            f = matlabFunction(fun,"Vars",{vars,obj.xtf});
        end
        function J = collocationJacobianFunction(obj)
            vars = obj.funvars(); 
            fun = jacobian(obj.confun(vars,obj.xtf),vars);
            J = matlabFunction(fun,"Vars",{vars,obj.xtf});
        end
        function Jtf = collocationJacobianFunctionFinalTime(obj)
            if ~isempty(obj.FinalTime)
                Jtf = function_handle.empty(0,1);
                return
            end
            vars = obj.funvars(); 
            fun = jacobian(obj.confun(vars,obj.xtf),obj.xtf); 
            Jtf = matlabFunction(fun,"Vars",{vars,obj.xtf});
        end
        function Ceq = constraint(obj,x,tf)
            X = reshape(x,[],obj.MeshSize);
            x0 = X(:,1:end - 1);
            x1 = X(:,2:end);
            Ceq = zeros(obj.f.NumStates,obj.MeshSize - 1,class(x));
            for k = 1:obj.MeshSize - 1
                Ceq(:,k) = obj.confun([x0(:,k);x1(:,k)],tf);
            end
            Ceq = [
                obj.f.InitialState - x0(1:obj.f.NumStates,1);
                Ceq(:);
                obj.f.FinalState - x1(1:obj.f.NumStates,end)
                ];
        end
        function GCeq = constraintJacobian(obj,x,tf)
            nx = obj.f.NumStates;
            nu = obj.f.NumControls;
            J = zeros(nx*(obj.MeshSize - 1),(nx + nu)*obj.MeshSize,class(x));
            X = reshape(x,[],obj.MeshSize);
            X0 = X(:,1:end - 1);
            X1 = X(:,2:end);
            for k = 1:obj.MeshSize - 1
                i = (k*nx - nx + 1):(k*nx);
                j = (k*(nx + nu) - (nx + nu) + 1):k*(nx + nu) + (nx + nu);
                J(i,j) = obj.confunjac([X0(:,k);X1(:,k)],tf);
            end
            I = eye(nx);
            GCeq = [
                [I,zeros(nx,size(J,2) - nx)];
                J;
                [zeros(nx,size(J,2) - (nx + nu)),-I,zeros(nx,nu)];
                ];
        end
        function GCeq = constraintJacobianMinimumTime(obj,x,tf)
            nx = obj.f.NumStates;
            Jx = obj.constraintJacobian(x,tf);
            Jtf = zeros(nx*(obj.MeshSize - 1),1,class(x));
            X = reshape(x,[],obj.MeshSize);
            X0 = X(:,1:end - 1);
            X1 = X(:,2:end);
            for k = 1:obj.MeshSize - 1
                i = (k*nx - nx + 1):(k*nx);
                Jtf(i,:) = obj.confunjactf([X0(:,k);X1(:,k)],tf);
            end
            Jtf = [
                zeros(nx,1);
                Jtf;
                zeros(nx,1);
                ];
            GCeq = [
                Jx,Jtf;
                ];
        end
    end
end