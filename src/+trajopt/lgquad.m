function [t,w] = lgquad(N)
%LGQUAD  Legendre–Gauss nodes and weights on [-1,1] via Golub–Welsch.
%   [t, w] = LGQUAD(N) returns the N-point Gauss–Legendre quadrature nodes t
%   (ascending) and weights w (both column vectors).
%
%   Requires: GOLUBWELSCH.M on the MATLAB path.
%
%   Example:
%       [t, w] = lgquad(4);
%       % t ≈ [-0.8611363116; -0.3399810436; 0.3399810436; 0.8611363116]
%       % w ≈ [ 0.3478548451;  0.6521451549; 0.6521451549; 0.3478548451]
%
%   Mapping to [a,b]:
%       x   = (b - a)/2 * t + (a + b)/2;
%       wab = (b - a)/2 * w;
    arguments
        N (1,1) double {mustBeFinite,mustBePositive,mustBeInteger};
    end

    alpha = zeros(N,1);
    beta = zeros(0,1);

    if N >= 2
        i = (1:N - 1)';
        beta = i./sqrt(4*i.^2 - 1);
    end

    [t,w] = trajopt.golubwelsch(alpha,beta,2);
end
