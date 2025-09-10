function cost(obj)
    arguments
        obj (1,1) trajopt.collocation.trap;
    end
    N = obj.NumIntervals;
    dt = diff(obj.Mesh)*(obj.FinalTime - obj.InitialTime);

    X = obj.States;
    U = obj.Controls;
    P = obj.Parameters;
    L = obj.LagrangeCost;
    L0 = L(X(:,1:N),U(:,1:N),P(:,1:N));
    Lf = L(X(:,2:end),U(:,2:end),P(:,2:end));

    JL = (L0 + Lf)*dt'/2;
    JM = obj.MayerCost(X(:,1),obj.InitialTime,X(:,end),obj.FinalTime);

    obj.Problem.minimize(JL + JM);
end