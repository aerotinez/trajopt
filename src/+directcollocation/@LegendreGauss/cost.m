function cost(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss
    end

    J = casadi.MX(0);

    if ~isempty(obj.LagrangeCost)
        L = obj.LagrangeCost;

        if obj.NumParameters > 0
            P = obj.Parameters;
        else
            P = casadi.MX.zeros(0, obj.NumNodes);
        end

        Lmap   = L.map(obj.NumNodes);
        Lnodes = Lmap(obj.States, obj.Controls, P);   % 1×N

        W  = casadi.DM(obj.QuadratureWeights);        % 1×N
        hT = obj.FinalTime - obj.InitialTime;

        J = J + hT * W * Lnodes.';      % scalar
    end

    if ~isempty(obj.MayerCost)
        a0 = directcollocation.baryval(obj.BarycentricWeights, obj.Mesh, 0.0); % 1×N
        a1 = directcollocation.baryval(obj.BarycentricWeights, obj.Mesh, 1.0); % 1×N

        x0 = obj.States * a0.';    % nx×1
        xf = obj.States * a1.';    % nx×1
        t0 = obj.InitialTime;
        tf = obj.FinalTime;

        J = J + obj.MayerCost(x0, t0, xf, tf);
    end

    obj.Problem.minimize(J);
end