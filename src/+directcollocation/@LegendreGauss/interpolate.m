function [t, x, u, p] = interpolate(obj, ns)
    arguments
        obj (1,1) directcollocation.LegendreGauss
        ns  (1,1) double {mustBeInteger, mustBePositive} = 200
    end

    sol = obj.Solution;

    X = sol.value(obj.States);            % nx×N
    U = sol.value(obj.Controls);          % nu×N
    if obj.NumParameters > 0
        P = sol.value(obj.Parameters);    % np×N
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

    s  = linspace(0, 1, ns).';                       % ns×1
    Ls = directcollocation.baryval(obj.BarycentricWeights, obj.Mesh, s.');  % ns×N

    % outputs: t column; x,u,p as (samples × variables)
    t = t0 + (tf - t0) * s;                          % ns×1
    x = Ls * X.';                                    % ns×nx
    u = Ls * U.';                                    % ns×nu

    if obj.NumParameters > 0
        p = Ls * P.';                                % ns×np
    else
        p = [];
    end
end