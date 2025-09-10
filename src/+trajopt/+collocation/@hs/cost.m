function cost(obj)
    arguments
        obj (1,1) trajopt.collocation.hs
    end

    N = obj.NumNodes;
    idx0 = 1:2:N - 1;
    idxm = 2:2:N - 1;
    idxf = 3:2:N;
    
    dt = (obj.Mesh(idxf) - obj.Mesh(idx0))*(obj.FinalTime - obj.InitialTime);

    X = obj.States;
    U = obj.Controls;
    P = obj.Parameters;
    L = obj.LagrangeCost;
    L0 = L(X(:,idx0),U(:,idx0),P(:,idx0));
    Lm = L(X(:,idxm),U(:,idxm),P(:,idxm));
    Lf = L(X(:,idxf),U(:,idxf),P(:,idxf));

    JL = (L0 + 4*Lm + Lf)*dt'/6;
    JM = obj.MayerCost(X(:,1),obj.InitialTime,X(:,end),obj.FinalTime);

    obj.Problem.minimize(JL + JM);
end
