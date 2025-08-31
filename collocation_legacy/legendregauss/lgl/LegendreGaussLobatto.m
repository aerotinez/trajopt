classdef LegendreGaussLobatto < LG
    methods (Access = protected)
        function tau = collocationPoints(obj)
            [~,tau] = quadLobatto(obj.Problem.NumNodes);
        end
        function cost(obj)
            J = 0;
            w = quadLobatto(obj.Problem.NumNodes);
            X = obj.Plant.States.Variable;
            U = obj.Plant.Controls.Variable;
            L = obj.Objective.Lagrange(X,U).';
            [t0,tf] = obj.getTimes();
            J = J + ((tf - t0)/2).*(w*L);
            M = obj.Objective.Mayer(X(:,1),t0,X(:,end),tf);
            J = J + M;
            obj.Problem.Problem.minimize(J);
        end
        function defect(obj)
            tau = obj.collocationPoints(); 
            D = lagpoldiff(tau,tau);
            X = obj.Plant.States.Variable;
            U = obj.Plant.Controls.Variable;
            P = obj.Plant.Parameters;
            F = obj.Plant.Dynamics;
            [t0,tf] = obj.getTimes();
            dt = (tf - t0)./2;
            obj.Problem.Problem.subject_to(dt.*F(X,U,P) - X*D == 0); 
        end
    end
end