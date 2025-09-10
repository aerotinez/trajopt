function c = baryweights(x)
%BARYWEIGHTS  First-form barycentric weights for nodes x.
%   c = BARYWEIGHTS(x) returns the weights c_j = 1 / prod_{m≠j} (x_j - x_m),
%   as a column vector the same length as x.
%
%   Notes:
%     - Only ratios c_j/c_i are used in barycentric differentiation, so c may
%       be multiplied by any nonzero constant; we normalize to avoid extremes.
%     - x entries must be distinct.
%
%   Example:
%     x = [-1; -0.5; 0.3; 1];
%     c = baryweights(x);
    arguments
        x (:,1) double {mustBeReal,mustBeFinite};
    end

    validateattributes(x,'double',{'numel',numel(unique(x))},mfilename,'x',1);
    n = numel(x);

    DX = x - x.';
    S  = sign(DX);     
    S(1:n + 1:end) = 1;

    A = abs(DX);     
    A(1:n + 1:end) = 1;

    mag = exp(-sum(log(A),2));
    c = prod(S,2).*mag;
    c = c./max(abs(c));
end
