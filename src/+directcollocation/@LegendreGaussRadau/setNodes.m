function setNodes(obj)
    arguments
        obj (1,1) directcollocation.LegendreGaussRadau
    end

    % Collocation count (Radau): Nc = NumNodes - 1
    Nc = obj.NumNodes - 1;
    assert(Nc >= 1, 'LegendreGaussRadau requires at least 1 collocation point.');

    % Special case Nc = 1: only the included endpoint is collocated → no interior roots
    if Nc == 1
        obj.Nodes = [-1, 1];
        return
    end

    % Interior Radau roots depend on which endpoint is included
    % Include -1  → roots of  P_Nc(x) + P_{Nc-1}(x)  in (-1,1)
    % Include +1  → roots of  P_Nc(x) - P_{Nc-1}(x)  in (-1,1)
    if obj.IncludedEndPoint == -1
        interior = radau_interior_roots(Nc, +1);  % +1 means use PN + PNm1
    else
        interior = radau_interior_roots(Nc, -1);  % -1 means use PN - PNm1
    end

    % Assemble augmented node set in ascending order: [-1, interior..., +1]
    obj.Nodes = [-1, interior(:).', 1];
end

% ---- helpers (local to file) ---------------------------------------------

function roots_interior = radau_interior_roots(N, signFlag)
% Compute the N-1 interior roots of Q_N(x) = P_N(x) + signFlag*P_{N-1}(x)
% signFlag = +1 → Radau including -1
% signFlag = -1 → Radau including +1

    K = N - 1;                       % number of interior roots
    x = -cos((1:K) * pi / N);        % Chebyshev-Lobatto interior as initial guess

    tol   = 1e-14;
    maxit = 100;

    for it = 1:maxit
        [PN, dPN]     = legendreP_and_dP(N, x);
        [PNm1, dPNm1] = legendreP_and_dP(N-1, x);

        f  = PN + signFlag * PNm1;
        df = dPN + signFlag * dPNm1;

        dx = - f ./ df;
        x  = x + dx;

        if max(abs(dx)) < tol, break; end
    end

    roots_interior = sort(x);
end

function [P, dP] = legendreP_and_dP(n, x)
% Evaluate Legendre P_n(x) and derivative via three-term recurrence
    x = x(:).';
    if n == 0
        P  = ones(size(x));
        dP = zeros(size(x));
        return
    end
    Pm1 = ones(size(x)); % P0
    P   = x;             % P1
    if n > 1
        for k = 1:n-1
            Pp1 = ((2*k+1)*x.*P - k*Pm1)/(k+1);
            Pm1 = P;
            P   = Pp1;
        end
    end
    % Derivative: P'_n(x) = n/(x^2-1) * (x P_n(x) - P_{n-1}(x))
    dP = n * (x.*P - Pm1) ./ (x.^2 - 1);
end
