classdef LegendreGauss < LG 
    methods (Access = protected) 
        function tau = collocationPoints(obj)
            N = obj.Problem.NumNodes - 2;
            tau = sort(roots(legpol(N))).';
        end 
        function cost(obj)
            J = 0;
            w = quadLegendreGauss(obj.Problem.NumNodes - 2); 
            X = obj.Plant.States.Variable(:,1:end - 1);
            U = obj.Plant.Controls.Variable(:,1:end - 1);
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
            X = obj.Plant.States.Variable(:,1:end - 1);
            U = obj.Plant.Controls.Variable(:,1:end - 1);
            P = obj.Plant.Parameters(:,1:end - 1);
            XLG = X(:,2:end);
            ULG = U(:,2:end);
            PLG = P(:,2:end);
            F = obj.Plant.Dynamics;
            [t0,tf] = obj.getTimes();
            dt = (tf - t0)./2;
            obj.Problem.Problem.subject_to(dt.*F(XLG,ULG,PLG) - X*D == 0);
            w = quadLegendreGauss(obj.Problem.NumNodes - 2).'; 
            X0 = X(:,1);
            Xf = obj.Plant.States.Variable(:,end);
            obj.Problem.Problem.subject_to(Xf == X0 + dt.*F(XLG,ULG,PLG)*w);
        end 
    end
end