function [t, x, u, p] = interpolate(obj, ns)
    arguments
        obj (1,1) directcollocation.HermiteSimpson
        ns  (1,1) double {mustBeInteger, mustBePositive} = 10
    end

    sol = obj.Solution;

    X = sol.value(obj.States);            % nx × Nn
    U = sol.value(obj.Controls);          % nu × Nn

    if obj.NumParameters > 0
        P = sol.value(obj.Parameters);    % np × Nn
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

    Nn = obj.NumNodes;
    nx = obj.NumStates;
    nu = obj.NumControls;
    np = obj.NumParameters;

    % macro-intervals = (Nn-1)/2, samples per macro-interval = ns
    M  = (Nn - 1) / 2;
    total = M * ns + 1;

    t = zeros(total, 1);
    x = zeros(total, nx);
    u = zeros(total, nu);

    if np > 0
        p = zeros(total, np);
    else
        p = [];
    end

    idx = 1;

    for m = 0:(M-1)
        i = 2*m + 1;           % left endpoint index (1-based)

        tL = Tnodes(i);
        tR = Tnodes(i+2);
        hk = tR - tL;

        tk = linspace(tL, tR, ns + 1);
        if m > 0
            tk = tk(2:end);
        end

        s = (tk - tL) / hk;    % normalized 0..1

        % Hermite cubic basis on states
        H1 = 1 - 3*s.^2 + 2*s.^3;
        H2 = 3*s.^2 - 2*s.^3;
        H3 = s - 2*s.^2 + s.^3;
        H4 = -s.^2 + s.^3;

        xL = X(:, i);
        xM = X(:, i+1);  %#ok<NASGU>  % not needed for cubic; already enforced by HS
        xR = X(:, i+2);

        uL = U(:, i);
        uM = U(:, i+1);
        uR = U(:, i+2);

        if np > 0
            pL = P(:, i);
            pM = P(:, i+1);
            pR = P(:, i+2);
        end

        % endpoint slopes from solved nodes
        if np > 0
            fL = full(obj.Plant(xL, uL, pL));
            fR = full(obj.Plant(xR, uR, pR));
        else
            fL = full(obj.Plant(xL, uL, []));
            fR = full(obj.Plant(xR, uR, []));
        end

        Xseg = xL * H1 + xR * H2 + hk * (fL * H3 + fR * H4);  % nx × m

        % quadratic Lagrange basis for controls/params at s ∈ [0,1]
        l0 = 2*(s - 0.5) .* (s - 1);   % node at s=0
        l1 = 4*s .* (1 - s);           % node at s=0.5
        l2 = 2*s .* (s - 0.5);         % node at s=1

        Useg = uL * l0 + uM * l1 + uR * l2;                 % nu × m
        if np > 0
            Pseg = pL * l0 + pM * l1 + pR * l2;             % np × m
        end

        mlen = numel(tk);

        t(idx:idx+mlen-1, 1) = tk(:);
        x(idx:idx+mlen-1, :) = Xseg.';   % m × nx
        u(idx:idx+mlen-1, :) = Useg.';   % m × nu
        if np > 0
            p(idx:idx+mlen-1, :) = Pseg.'; % m × np
        end

        idx = idx + mlen;
    end
end
