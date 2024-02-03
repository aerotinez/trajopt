classdef nlp < handle
    properties (GetAccess = public, SetAccess = private)
        Variables;
        Mesh;
        Aeq;
        beq;
        lb;
        ub;
    end
    properties (Access = protected)
        Cost;
        Constraints; 
    end
    methods (Access = public)
        function obj = nlp(variables,mesh,cost,constraints,Aeq,beq,lb,ub)
            arguments
                variables (1,1) nlpvars;
                mesh (1,1) nlpmesh;
                cost ocpcost;
                constraints ocpcon;
                Aeq (:,:) double = [];
                beq (:,1) double = [];
                lb (:,1) double = [];
                ub (:,1) double = [];
            end
            obj.Mesh = mesh;
            obj.Variables = variables;
            obj.Cost = cost;
            obj.Constraints = constraints;
            obj.Aeq = Aeq;
            obj.beq = beq;
            obj.lb = lb;
            obj.ub = ub;
        end
        function solve(obj,opts)
            fcost = @obj.objective;
            fcon = @obj.nonlcon;
            z0 = obj.Variables.get();
            z = fmincon(fcost,z0,[],[],obj.Aeq,obj.beq,obj.lb,obj.ub,fcon,opts);
            obj.Variables.set(z); 
        end 
    end 
    methods (Access = private)
        function J = objective(obj,z)
            [t0,tf,x,u] = obj.Variables.unpack(z);
            x0 = x(:,1);
            xf = x(:,end);
            M = obj.Cost.Mayer(x0,t0,xf,tf);
            w = obj.Cost.Lagrange(x,u).';
            dm = diff(obj.Mesh.Mesh);
            dt = (tf - t0);
            b = (1/2).*sum([dm,0;0,dm],1);
            q = dt.*w;
            L = b*q;
            J = M + L;
        end
        function [C,Ceq] = nonlcon(obj,z)
            C = [];
            Ceq = [
                obj.dynamicConstraints(z);
            ];
        end
    end
    methods (Access = protected, Abstract)
        Ceq = dynamicConstraints(obj,z);
    end
    methods (Access = public, Abstract)
        fig = plot(rows,cols);
    end
end