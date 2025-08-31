function L = baryval(weights, nodes, x)
%BARYVAL  Barycentric Lagrange basis values at query points.
%
%   L = BARYVAL(weights, nodes, x) returns the matrix of Lagrange basis
%   values evaluated at the points in x, using the first-form barycentric
%   formula with the supplied barycentric weights.
%
%   INPUT
%     weights  (1×N double)  First-form barycentric weights λ_j associated
%               with 'nodes'. Only their relative values matter (any common
%               nonzero scaling leaves the result unchanged).
%
%     nodes    (1×N double)  Interpolation nodes corresponding to 'weights'.
%               Must be finite and real. (Use BARYFIT to compute weights.)
%
%     x        (1×M double)  Query points at which to evaluate the Lagrange
%               basis on the normalized domain of 'nodes'.
%
%   OUTPUT
%     L        (M×N double)  Basis matrix whose (i,j) entry is the j-th
%               Lagrange cardinal polynomial evaluated at x(i):
%                   L(i,j) = ℓ_j(x(i))
%               Each row of L sums to 1. If x(i) coincides with nodes(k),
%               then L(i,:) is the k-th canonical row vector (…0 1 0…).
%
%   USAGE
%     % Given nodal values y_j at 'nodes', the interpolant at x is:
%     y_at_x = L * y(:);                  % (M×1)
%
%   NOTES
%   • This routine uses the stable barycentric evaluation:
%       ℓ_j(z) = (λ_j / (z - x_j)) / Σ_k (λ_k / (z - x_k)).
%     Exact node hits are handled explicitly to avoid division by zero.
%   • Complexity: O(M·N). For typical pseudospectral grids (tens–hundreds
%     of nodes), this is perfectly acceptable.
%
%   EXAMPLE
%     N = 6;
%     t = cos(pi*(0:N)/N);     % Chebyshev–Lobatto nodes on [-1,1]
%     s = (t + 1)/2;           % map to [0,1]
%     w = baryfit(s);          % first-form weights
%     xq = linspace(0,1,101);
%     L  = baryval(w, s, xq);  % basis values at query points
%
%   SEE ALSO  baryfit
%
%   Copyright (c) Your Name. All rights reserved.

    arguments
        weights (1,:) double {mustBeReal,mustBeFinite,mustBeNonNan}
        nodes   (1,:) double {mustBeReal,mustBeFinite,mustBeNonNan}
        x       (1,:) double {mustBeReal,mustBeFinite,mustBeNonNan}
    end

    % ---- Coerce/validate sizes -------------------------------------------
    w = weights;                         % 1×N
    t = nodes;                           % 1×N
    validateattributes(t, {'double'}, {'row','numel',numel(w)}, ...
                       mfilename, 'nodes');

    z = x(:);                            % M×1
    n = numel(t);
    m = numel(z);

    % ---- Evaluate basis row-by-row (stable barycentric form) -------------
    L = zeros(m, n);

    for i = 1:m
        dif = z(i) - t;                  % 1×N differences (z - x_j)
        k = find(dif == 0, 1);           % exact node hit?

        if ~isempty(k)
            % ℓ_k(z)=1, all others 0
            row = zeros(1, n);
            row(1, k) = 1;
            L(i, :) = row;
        else
            tmp = w ./ dif;              % 1×N numerators λ_j/(z - x_j)
            s   = sum(tmp);              % scalar denominator
            L(i, :) = tmp / s;           % ℓ_j(z(i))
        end
    end
end
