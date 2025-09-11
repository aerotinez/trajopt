function J = smoothCost(obj)
    arguments
        obj (1,1) trajopt.collocation.LegendrePseudospectral;
    end
    t0 = obj.InitialTime;
    tf = obj.FinalTime;

    D = obj.DifferentiationMatrix';
    Dc = trajopt.barydiff(obj.Nodes(obj.CollocationIndices))';
    W = diag(obj.QuadratureWeights);

    X = obj.States';
    U = obj.Controls';

    Jx = 0;
    for k = 1:3
        a = (2^(2*k - 1))/((tf - t0)^(2*k - 1));
        E = (Dc^(k - 1))*D;
        H = E'*W*E;
        Jk = X'*H*X;
        Jx = Jx + a*sum(Jk(:));
    end

    Ju = 0;
    for k = 1:2
        a = (2^(2*k - 1))/((tf - t0)^(2*k - 1));
        E = Dc^k;
        H = E'*W*E;
        Jk = U'*H*U;
        Ju = Ju + a*sum(Jk(:));
    end

    J = Jx + Ju;
end