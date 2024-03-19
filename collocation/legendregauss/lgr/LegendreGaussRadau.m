classdef LegendreGaussRadau < LG
    methods (Access = protected)
        function tau = collocationPoints(obj)
            N = obj.Problem.NumNodes - 2;
            tau = [sort(roots(legpol(N))).',1];
        end 
        function cost(obj)
            J = 0;
            w = obj.quadratureWeights(); 
            X = obj.Plant.States.Variable;
            U = obj.Plant.Controls.Variable;
            XLG = X(:,2:end);
            ULG = U(:,2:end);
            L = obj.Objective.Lagrange(XLG,ULG).';
            [t0,tf] = obj.getTimes();
            J = J + ((tf - t0)/2).*(w*L);
            M = obj.Objective.Mayer(X(:,1),t0,X(:,end),tf);
            J = J + M;
            obj.Problem.Problem.minimize(J);
        end
        function defect(obj)
            tau = obj.collocationPoints(); 
            D = lagpoldiff([-1,tau],tau);
            X = obj.Plant.States.Variable;
            U = obj.Plant.Controls.Variable;
            P = obj.Plant.Parameters;
            XLG = X(:,2:end);
            ULG = U(:,2:end);
            PLG = P(:,2:end);
            F = obj.Plant.Dynamics;
            [t0,tf] = obj.getTimes();
            dt = (tf - t0)./2;
            obj.Problem.Problem.subject_to(dt.*F(XLG,ULG,PLG) - X*D == 0); 
        end
    end
end