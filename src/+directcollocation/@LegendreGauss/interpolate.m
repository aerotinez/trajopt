function [t, x, u, p] = interpolate(obj, ns)
    arguments
        obj (1,1) directcollocation.LegendreGauss
        ns  (1,1) double {mustBeInteger,mustBePositive} = 20
    end

    % ---- Pull numeric values from the solved problem ----
    % States at augmented nodes: size nx × (N+2)
    X = obj.Problem.value(obj.States);

    % Controls at Gauss nodes: size nu × N
    U = obj.Problem.value(obj.Controls);

    % Parameters at Gauss nodes (CasADi parameters, not decision variables)
    if obj.NumParameters > 0
        Pvals = obj.Problem.value(obj.Parameters);  % np × N
        np = size(Pvals,1);
    else
        Pvals = [];
        np = 0;
    end

    % Times
    t0 = obj.Problem.value(obj.InitialTime);
    tf = obj.Problem.value(obj.FinalTime);

    % ---- Node sets in tau ∈ [-1,1] ----
    % Augmented nodes for states: [-1, τ_G, +1] length N+2
    tauS = obj.Nodes(:).';                     % 1 × (N+2)

    % Gauss nodes for controls/parameters: extract interior (length N)
    tauG = obj.Nodes(2:end-1);                 % 1 × N

    Nn = numel(tauS);                          % N+2

    % ---- Build sample grid in tau (uniform per interval in tau; t is affine in tau) ----
    total = ns*(Nn-1) + 1;
    tauSample = zeros(1, total);
    idx = 1;
    for k = 1:(Nn-1)
        seg = linspace(tauS(k), tauS(k+1), ns+1);
        if k > 1
            seg = seg(2:end);                  % avoid duplicates at interfaces
        end
        m = numel(seg);
        tauSample(idx:idx+m-1) = seg;
        idx = idx + m;
    end

    % Map tau → time
    t = 0.5*(tauSample + 1)*(tf - t0) + t0;    % 1 × M
    t = t(:);                                  % M × 1

    % ---- Evaluate Lagrange interpolants ----
    % States use basis on augmented nodes tauS
    LS = lagrange_basis_matrix(tauS, tauSample);    % M × (N+2)

    % Controls/parameters use basis on Gauss nodes tauG
    LG = lagrange_basis_matrix(tauG, tauSample);    % M × N

    % Interpolate
    x = (LS * X.').';                          % (M×(N+2))·((N+2)×nx) → M×nx, then transpose -> nx×M ->'
    x = x.';                                   % M × nx

    u = (LG * U.').';                          % M×nu, then -> nu×M ->'
    u = u.';                                   % M × nu

    if np > 0
        p = (LG * Pvals.').';                  % M×np -> np×M ->'
        p = p.';                               % M × np
    else
        p = [];
    end
end

% ----- local helper -----
function L = lagrange_basis_matrix(nodes, s, tol)
% L(i,j) = ℓ_j(s_i) where {ℓ_j} are Lagrange polynomials on 'nodes'
% nodes: 1×K, s: 1×M
    if nargin < 3 || isempty(tol), tol = 1e-14; end
    nodes = nodes(:).';
    K = numel(nodes);
    M = numel(s);

    % Precompute denominators denom_j = ∏_{m≠j} (x_j - x_m)
    denom = ones(1, K);
    for j = 1:K
        diffj = nodes(j) - nodes;
        diffj(j) = 1;                  % skip self
        denom(j) = prod(diffj);
    end

    L = zeros(M, K);
    for i = 1:M
        si = s(i);
        % exact node hit -> Kronecker delta row
        hit = find(abs(si - nodes) <= tol, 1, 'first');
        if ~isempty(hit)
            L(i, hit) = 1;
            continue
        end

        % compute ℓ_j(si) via first-form (O(K^2), explicit Lagrange)
        % ℓ_j(si) = ∏_{m≠j} (si - x_m) / ∏_{m≠j} (x_j - x_m)
        for j = 1:K
            num = 1;
            for m = 1:K
                if m ~= j
                    num = num * (si - nodes(m));
                end
            end
            L(i, j) = num / denom(j);
        end
        % Optional normalization (not strictly needed if computed exactly)
        % rowSum = sum(L(i,:)); L(i,:) = L(i,:)/rowSum;
    end
end
