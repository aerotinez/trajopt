function D = baryder(weights, nodes, x)
%BARYDER  Derivatives of Lagrange basis at arbitrary points (barycentric).
%   D = BARYDER(W, T, X) returns an M-by-N matrix with D(i,j) = ℓ'_j(X(i)),
%   where {ℓ_j} are the Lagrange basis polynomials on nodes T(1..N) with
%   first-form barycentric weights W(1..N) = directcollocation.baryfit(T).
%
%   Stable for evaluation points X off the nodes and at nodes (uses the
%   standard limiting formula for rows where X(i) == T(j)).
%
%   Inputs:
%     weights  (1×N)  first-form barycentric weights for nodes T
%     nodes    (1×N)  interpolation nodes T
%     x        (1×M)  evaluation points
%
%   Output:
%     D        (M×N)  derivative matrix: D(i,j) = dℓ_j/dx evaluated at X(i)

    arguments
        weights (1,:) double {mustBeReal,mustBeFinite}
        nodes   (1,:) double {mustBeReal,mustBeFinite}
        x       (1,:) double {mustBeReal,mustBeFinite}
    end

    w = weights(:).';           % 1×N
    t = nodes(:).';             % 1×N
    z = x(:);                   % M×1
    N = numel(t);
    M = numel(z);
    D = zeros(M,N);

    for i = 1:M
        dif = z(i) - t;                         % 1×N
        hit = find(dif == 0, 1);
        if ~isempty(hit)
            % Row corresponding to evaluation exactly at a node t(hit)
            j = hit;
            row = zeros(1,N);
            for k = 1:N
                if k ~= j
                    row(k) = w(k) / ( w(j) * (t(j) - t(k)) );
                end
            end
            row(j) = -sum(row);
            D(i,:) = row;
        else
            r  = w ./ dif;                     % w_j/(x - t_j)
            S  = sum(r);
            L  = r / S;                        % basis values at z(i)
            S2 = sum( r ./ dif );              % sum w_j/(x - t_j)^2 divided by S later
            D(i,:) = L .* ( S2 / S - 1./dif );
        end
    end
end
