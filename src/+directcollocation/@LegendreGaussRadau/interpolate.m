function [t, x, u, p] = interpolate(obj, ns)
    arguments
        obj (1,1) directcollocation.LegendreGaussRadau
        ns  (1,1) double {mustBeInteger,mustBePositive} = 20
    end

    % ---- Pull numeric values from the solved problem ----
    X = obj.Problem.value(obj.States);         % nx × NumNodes
    U = obj.Problem.value(obj.Controls);       % nu × (NumNodes-1)

    if obj.NumParameters > 0
        Pvals = obj.Problem.value(obj.Parameters);   % np × (NumNodes-1)
        np = size(Pvals,1);
    else
        Pvals = [];
        np = 0;
    end

    t0 = obj.Problem.value(obj.InitialTime);
    tf = obj.Problem.value(obj.FinalTime);

    % ---- Node sets (τ ∈ [-1,1]) ----
    tauS = obj.Nodes(:).';                     % 1 × NumNodes (augmented)
    tauC = obj.Nodes(obj.CollocationIndices);  % 1 × (NumNodes-1) (collocation)

    Ns = numel(tauS);

    % ---- Build sample grid in τ (uniform per interval on the augmented set) ----
    total = ns*(Ns-1) + 1;
    tauSample = zeros(1, total);
    idx = 1;
    for k = 1:(Ns-1)
        seg = linspace(tauS(k), tauS(k+1), ns+1);
        if k > 1, seg = seg(2:end); end        % avoid duplicates
        m = numel(seg);
        tauSample(idx:idx+m-1) = seg;
        idx = idx + m;
    end

    % Map τ → time
    t = 0.5*(tauSample + 1)*(tf - t0) + t0;    % 1 × M
    t = t(:);                                  % M × 1

    % ---- Lagrange basis matrices ----
    % States on augmented nodes
    LS = lagrange_basis_matrix(tauS, tauSample);   % M × NumNodes
    % Controls/parameters on collocation nodes
    LC = lagrange_basis_matrix(tauC, tauSample);   % M × (NumNodes-1)

    % ---- Interpolate ----
    x = (LS * X.').';                         % -> M × nx, then transpose twice
    x = x.';                                  % M × nx

    u = (LC * U.').';
    u = u.';                                   % M × nu

    if np > 0
        p = (LC * Pvals.').';
        p = p.';                                % M × np
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
        diffj(j) = 1;              % skip self
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

        % Explicit Lagrange product (O(K^2))
        for j = 1:K
            num = 1;
            for m = 1:K
                if m ~= j
                    num = num * (si - nodes(m));
                end
            end
            L(i, j) = num / denom(j);
        end
    end
end
