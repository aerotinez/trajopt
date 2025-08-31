function w = baryfit(nodes)
%BARYFIT  First-form barycentric weights for Lagrange interpolation.
%
%   w = BARYFIT(nodes) returns the (scale-free) first-form barycentric
%   weights corresponding to the interpolation nodes in 'nodes'. These
%   weights are suitable for use with the barycentric evaluation formula,
%   e.g., with a companion function BARYVAL that computes the Lagrange
%   basis values or interpolant at arbitrary points.
%
%   INPUT
%     nodes  (1×N double)  Interpolation nodes (distinct, finite, real).
%            Orientation is flexible; row or column is accepted. Any NaN or
%            Inf entries are rejected.
%
%   OUTPUT
%     w      (1×N double)  Scale-free barycentric weights λ_j satisfying
%            λ_j = 1 / ∏_{k≠j} (x_j - x_k).  Only relative values matter:
%            c*w yields the same interpolant for any nonzero scalar c.
%            Returned as a row vector for convenience.
%
%   NOTES
%   • Robustness: products are formed via log-sums with sign tracking to
%     avoid overflow/underflow when N is large or nodes are clustered.
%   • Normalization: weights are rescaled by max|λ_j| to keep magnitudes
%     moderate. This does not affect interpolation (scale-free).
%   • Complexity: O(N^2) time and O(N^2) temporary storage for the
%     pairwise differences. This is acceptable for typical pseudospectral
%     node counts (tens to a few hundreds).
%
%   EXAMPLE
%     % Chebyshev–Lobatto nodes on [-1,1], mapped to [0,1]
%     N = 9;
%     t = cos(pi*(0:N)/N);       % [-1,1]
%     s = (t + 1)/2;             % [0,1]
%     w = baryfit(s);
%     % Evaluate Lagrange basis at midpoints with your BARYVAL:
%     % L = baryval(w, s, linspace(0,1,50));
%
%   SEE ALSO  baryval  % barycentric evaluation (basis/interpolant)
%
%   References:
%   - J.-P. Berrut and L. N. Trefethen, "Barycentric Lagrange Interpolation,"
%     SIAM Review, 46(3), 2004, pp. 501–517.
%
%   Copyright (c) Your Name. All rights reserved.

    arguments
        nodes (1,:) double {mustBeReal,mustBeFinite,mustBeNonNan}
    end

    % ---- Coerce to a column and validate distinctness --------------------
    x = nodes(:);                       % N×1
    n = numel(x);

    if numel(unique(x)) ~= n
        error('baryfit:DuplicateNodes', 'All nodes must be distinct.');
    end

    % ---- First-form barycentric weights (scale-free) ---------------------
    % λ_j = 1 / ∏_{k≠j} (x_j - x_k)
    %
    % Compute products robustly via sign and log-magnitude to avoid
    % overflow/underflow. The diagonal is skipped by setting it to 1.
    D = x - x.';                        % pairwise differences (N×N)
    D(1:n+1:end) = 1;                   % ignore diagonal terms
    sgn   = prod(sign(D), 2);           % sign of each product (N×1)
    logab = sum(log(abs(D)), 2);        % log |product| (N×1)
    wcol  = sgn ./ exp(logab);          % raw weights (N×1), scale-free

    % ---- Optional normalization (numerical hygiene) ----------------------
    % Scaling does not change the interpolant; this just tames magnitude.
    m = max(abs(wcol));
    if m > 0
        wcol = wcol / m;
    end

    % ---- Return as row vector --------------------------------------------
    w = wcol(:)';                      % 1×N
end
