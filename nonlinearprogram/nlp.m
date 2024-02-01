classdef nlp < handle
    properties (Access = public)
        Mesh;
        Variables;
        Aeq;
        beq;
        lb;
        ub;
    end
    properties (Access = private)
        CostFunction;
        Constraints; 
    end
    methods (Access = public)
        function obj = nlp(mesh,vars,cost_function,constraints,Aeq,beq,lb,ub)
            arguments
                mesh (1,1) nlpmesh;
                vars (1,1) nlpvars;
                cost_function ocpcost;
                constraints ocpcon;
                Aeq (:,:) double = [];
                beq (:,1) double = [];
                lb (:,1) double = [];
                ub (:,1) double = [];
            end
            obj.Mesh = mesh;
            obj.Variables = vars;
            obj.CostFunction = cost_function;
            obj.Constraints = constraints;
            obj.Aeq = Aeq;
            obj.beq = beq;
            obj.lb = lb;
            obj.ub = ub;
        end
        function solve(obj,dynfun,opts)
            f = @obj.objective;
            z0 = obj.pack();
            nonlcon = @(z)obj.nonlcon(dynfun,z);
            z = fmincon(f,z0,[],[],obj.Aeq,obj.beq,obj.lb,obj.ub,nonlcon,opts);
            [t0,tf,x,u] = obj.unpack(z);
            ist0free = obj.Variables.IsInitialTimeFree;
            istfree = obj.Variables.IsFinalTimeFree;
            obj.Variables = nlpvars(x,u,t0,ist0free,tf,istfree);
        end
        function J = objective(obj,z)
            [t0,tf,x,u] = obj.unpack(z);
            x0 = x(:,1);
            xf = x(:,end);
            M = obj.CostFunction.Mayer(x0,t0,xf,tf);
            w = obj.CostFunction.Lagrange(x,u).';
            dm = diff(obj.Mesh.Mesh);
            b = (1/2).*sum([dm(1:end - 1),0;0,dm(2:end)],1);
            h = dm.*(tf - t0);
            q = diag(h)*w;
            L = b*q;
            J = M + L;
        end
        function [C,Ceq] = nonlcon(obj,Cdyn,z)
            C = [];
            [t0,tf,x,u] = obj.unpack(z);
            h = diff(obj.Mesh.Mesh(1:end-1)).*(tf - t0);
            pdyn = [obj.Constraints.Dynamics.Parameters.Value].';
            fdyn = @(x,u)obj.Constraints.Dynamics.Plant(x,u,0,pdyn);
            x0 = x(:,1:end - 1);
            u0 = u(:,1:end - 1);
            xf = x(:,2:end);
            uf = u(:,2:end);
            Ceq = reshape(Cdyn(fdyn,x0,u0,xf,uf,h),[],1);
        end
    end 
end