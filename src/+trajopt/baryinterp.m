function L = baryinterp(x,xq)
%BARYINTERP  Barycentric interpolation matrix (weights computed internally).
%   L = BARYINTERP(x, xq) returns the matrix L such that Yq = L*Y interpolates
%   node values Y at query points xq using first-form barycentric weights.
%
%   x  : nodes (nx×1 or 1×nx), distinct
%   xq : query points (nq×1 or 1×nq)
%   L  : nq×nx

    arguments
        x  double {mustBeReal, mustBeFinite}
        xq double {mustBeReal, mustBeFinite}
    end
    x  = x(:);                  % nx×1
    xq = xq(:);                 % nq×1
    nx = numel(x);
    nq = numel(xq);
    assert(numel(unique(x)) == nx, 'baryL:distinct', 'Nodes must be distinct.');

    % First-form barycentric weights on the given node set
    c = trajopt.baryweights(x);         % nx×1

    % Differences and on-node detection
    D   = xq - x.';             % nq×nx
    tol = 10*eps(max(1, max(abs(x))));
    on  = abs(D) <= tol;        % exact (within tol) hits

    L = zeros(nq, nx);

    % Rows without exact hits: standard barycentric formula
    mask = ~any(on, 2);
    if any(mask)
        W = c.' ./ D(mask, :);          % nq_m×nx
        L(mask, :) = W ./ sum(W, 2);
    end

    % Rows with exact-node hits: set to unit vectors
    if any(on, 'all')
        [rq, cj] = find(on);
        for k = 1:numel(rq)
            L(rq(k), :) = 0;
            L(rq(k), cj(k)) = 1;
        end
    end
end
