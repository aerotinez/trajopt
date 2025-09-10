function D = barydiff(x)
%BARYDIFF  Full barycentric differentiation matrix on nodes x.
%   D = BARYDIFF(x) returns D(j,i) = ℓ′_j(x_i) for the Lagrange basis on x.
%   Uses first-form barycentric weights c_j = 1 / ∏_{m≠j} (x_j - x_m).
%
%   Input:
%     x : vector of distinct nodes (Ns×1 or 1×Ns)
%   Output:
%     D : Ns×Ns differentiation matrix (columns sum to zero)
    arguments
        x (:,1) double {mustBeReal,mustBeFinite};
    end

    x  = x(:);                     % Ns×1
    validateattributes(x,'double',{'numel',numel(unique(x))},mfilename,'x',1);
    Ns = numel(x);

    c = trajopt.baryweights(x);            % Ns×1 (any common scale)

    % Ratios c_j/c_i and differences x_i - x_j
    R = c*(1./c.');         % Ns×Ns, R(j,i) = c_j / c_i
    Diff = x.' - x;         % Ns×Ns, Diff(j,i) = x_i - x_j
    Diff(1:Ns + 1:end) = 1; % avoid division by zero on the diagonal

    % Off-diagonals
    D = R./Diff;
    D(1:Ns + 1:end) = 0;

    % Diagonals so each column sums to zero (ℓ′ applied to constants = 0)
    D(1:Ns + 1:end) = -sum(D,1).';
end
