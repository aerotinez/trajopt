function x = golubwelsch(n, alpha, beta)
%GOLUBWELSCH  Gauss–Jacobi interior nodes on [-1,1] via Golub–Welsch.
%
%   x = GOLUBWELSCH(n, alpha, beta) returns the n Gauss–Jacobi nodes
%   (no endpoints) for weight (1 - x)^alpha (1 + x)^beta on [-1,1],
%   sorted ascending.
%
%   INPUT
%     n      (1,1)  integer, n >= 0   (# of interior nodes)
%     alpha  (1,1)  real,   alpha > -1
%     beta   (1,1)  real,   beta  > -1
%
%   OUTPUT
%     x      (n×1)  nodes in (-1,1), ascending
%
%   Notes
%   • For Legendre (alpha=beta=0), a_0 should be exactly 0; the generic
%     formula gives 0/0, so we set a(1)=0 explicitly.
%   • Use n = N-1 for Radau interiors, n = N-2 for Lobatto interiors.

    arguments
        n      (1,1) double {mustBeInteger,mustBeNonnegative}
        alpha  (1,1) double {mustBeReal}
        beta   (1,1) double {mustBeReal}
    end

    if n == 0
        x = zeros(0,1);
        return
    end

    if ~(alpha > -1 && beta > -1)
        error('golubwelsch:BadParams', ...
            'alpha and beta must both be greater than -1.');
    end

    % ---- Diagonal entries a_k (k=0..n-1) ---------------------------------
    k0 = (0:n-1).';
    denom = (2*k0 + alpha + beta) .* (2*k0 + alpha + beta + 2);
    a = (beta^2 - alpha^2) ./ denom;

    % Fix the removable singularity at k=0 when alpha+beta == 0 (Legendre)
    if abs(alpha + beta) < eps
        a(1) = 0;
    end

    % ---- Off-diagonals b_k (k=1..n-1), strictly positive -----------------
    if n > 1
        k = (1:n-1).';
        num  = k .* (k + alpha) .* (k + beta) .* (k + alpha + beta);
        den  = (2*k + alpha + beta - 1) .* (2*k + alpha + beta + 1);
        b = 2 ./ (2*k + alpha + beta) .* sqrt(num ./ den);
    else
        b = zeros(0,1);
    end

    % ---- Symmetric tridiagonal Jacobi matrix and eigenvalues -------------
    J = diag(a) + diag(b, 1) + diag(b, -1);
    x = sort(eig(J), 'ascend');      % column, interior nodes in (-1,1)
end
