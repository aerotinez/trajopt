function [t, x, u, p] = interpolate(obj, ns)
    arguments
        obj (1,1) directcollocation.Trapezoidal
        ns  (1,1) double {mustBeInteger, mustBePositive} = 10
    end

    sol = obj.Solution;

    X = sol.value(obj.States);          % nx × (N+1)
    U = sol.value(obj.Controls);        % nu × (N+1)

    if obj.NumParameters > 0
        P = sol.value(obj.Parameters);  % np × (N+1)
    else
        P = [];
    end

    t0 = sol.value(obj.InitialTime);
    if isempty(t0)
        t0 = obj.InitialTime;
    end

    tf = sol.value(obj.FinalTime);
    if isempty(tf)
        tf = obj.FinalTime;
    end

    Tnodes = t0 + (tf - t0) .* obj.Mesh;

    N  = obj.NumIntervals;
    nx = obj.NumStates;
    nu = obj.NumControls;
    np = obj.NumParameters;

    total = N * ns + 1;

    t = zeros(total, 1);
    x = zeros(total, nx);
    u = zeros(total, nu);

    if np > 0
        p = zeros(total, np);
    else
        p = [];
    end

    if np == 0
        pempty = zeros(0,1);
    end

    idx = 1;

    for k = 1:N
        tL = Tnodes(k);
        tR = Tnodes(k+1);
        hk = tR - tL;

        tk = linspace(tL, tR, ns + 1);
        if k > 1
            tk = tk(2:end);
        end

        m    = numel(tk);
        tau  = tk - tL;        % 1×m
        alpha = tau / hk;      % 1×m

        Uk   = U(:, k);
        Ukp1 = U(:, k+1);
        Useg = Uk   * (1 - alpha) + Ukp1 * alpha;      % nu × m

        if np > 0
            Pk   = P(:, k);
            Pkp1 = P(:, k+1);
            Pseg = Pk * (1 - alpha) + Pkp1 * alpha;     % np × m
        end

        Xk   = X(:, k);
        Xkp1 = X(:, k+1);

        if np > 0
            fk   = full(obj.Plant(Xk,   Uk,   P(:, k)));    % nx × 1
            fkp1 = full(obj.Plant(Xkp1, Ukp1, P(:, k+1))); % nx × 1
        else
            fk   = full(obj.Plant(Xk,   Uk,   pempty));
            fkp1 = full(obj.Plant(Xkp1, Ukp1, pempty));
        end

        Xseg = Xk * ones(1, m) + fk * tau + (fkp1 - fk) * ((tau.^2) / (2 * hk)); % nx × m

        t(idx:idx+m-1, 1) = tk(:);
        x(idx:idx+m-1, :) = Xseg.';     % m × nx
        u(idx:idx+m-1, :) = Useg.';     % m × nu

        if np > 0
            p(idx:idx+m-1, :) = Pseg.'; % m × np
        end

        idx = idx + m;
    end
end
