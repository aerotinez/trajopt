function [x,w] = golubwelsch(alpha,beta,mu0)
%GOLUBWELSCH  Nodes & weights from a Jacobi (tridiagonal) matrix.
%   [x, w] = GOLUBWELSCH(alpha, beta, mu0) computes the quadrature nodes x
%   (ascending) and weights w from the symmetric tridiagonal Jacobi matrix
%   J = diag(alpha) + diag(beta,1) + diag(beta,-1).
%   The weights are w_k = mu0 * (V(1,k))^2, where V are J's normalized
%   eigenvectors and mu0 = ∫ 1 * w(x) dx (zeroth moment of the weight).
%
%   Inputs:
%     alpha : N×1 double  (diagonal of J)
%     beta  : (N-1)×1 double (off-diagonal of J)
%     mu0   : scalar double > 0 (zeroth moment)
%
%   Example: Gauss–Legendre N=4
%       N = 4;
%       i = (1:N-1).';
%       beta = i ./ sqrt(4*i.^2 - 1);    % Legendre off-diagonals
%       alpha = zeros(N,1);
%       [x,w] = golubwelsch(alpha, beta, 2);

    arguments
        alpha (:,1) double {mustBeReal,mustBeFinite};
        beta  (:,1) double {mustBeReal,mustBeFinite};
        mu0   (1,1) double {mustBeReal,mustBeFinite,mustBePositive};
    end
    
    validateattributes(alpha,'double',{'nonempty'},mfilename,'alpha',1);
    N = numel(alpha);

    validateattributes(beta,'double',{'numel',N - 1},mfilename,'beta',2);

    J = diag(alpha) + diag(beta,1) + diag(beta,-1);
    [V,D] = eig(J,'vector');

    [x,idx] = sort(D,'ascend');
    V = V(:,idx);

    w = mu0*(V(1,:).^2)';
end
