classdef LegendreGaussRadau < LG
    methods (Access = protected)
        function tau = collocationPoints(obj)
            [~,tau] = quadRadau(obj.Problem.NumNodes - 1);
        end 
        function cost(obj)
            J = 0;
            w = quadRadau(obj.Problem.NumNodes - 1); 
            X = obj.Plant.States.Variable;
            U = obj.Plant.Controls.Variable;
            P = obj.Plant.Parameters;
            XLG = X(:,1:end - 1);
            ULG = U(:,1:end - 1);
            PLG = P(:,1:end - 1);
            L = obj.Objective.Lagrange(XLG,ULG,PLG).';
            [t0,tf] = obj.getTimes();
            J = J + ((tf - t0)/2).*(w*L);
            M = obj.Objective.Mayer(X(:,1),t0,X(:,end),tf);
            J = J + M;
            obj.Problem.Problem.minimize(J);
        end
        function defect(obj)
            tau = obj.collocationPoints(); 
            D = lagpoldiff([tau,1],tau);
            X = obj.Plant.States.Variable;
            U = obj.Plant.Controls.Variable;
            P = obj.Plant.Parameters;
            XLG = X(:,1:end - 1);
            ULG = U(:,1:end - 1);
            PLG = P(:,1:end - 1);
            F = obj.Plant.Dynamics;
            [t0,tf] = obj.getTimes();
            dt = (tf - t0)./2;
            obj.Problem.Problem.subject_to(dt.*F(XLG,ULG,PLG) - X*D == 0); 
        end
    end
end