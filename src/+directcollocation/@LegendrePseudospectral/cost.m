function cost(obj)
    arguments
        obj (1,1) directcollocation.LegendrePseudospectral;
    end

    w = obj.QuadratureWeights; 
    t0 = obj.InitialTime;
    tf = obj.FinalTime;

    X = obj.States;
    XLG = obj.States(:,obj.CollocationIndices);
    U = obj.Controls;
    P = obj.Parameters;

    L = ((tf - t0)/2)*w*obj.LagrangeCost(XLG,U,P)';

    M = obj.MayerCost(X(:,1),t0,X(:,end),tf);

    J = L + M + smoothCost(obj,1E-01,1E-02,1E-03);

    obj.Problem.minimize(J);
end