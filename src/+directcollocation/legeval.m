function Pn = legeval(n, x)
%LEGEVAL  Evaluate the Legendre polynomial P_n(x) via 3-term recurrence.
%
%   Pn = LEGEVAL(n, x) returns P_n evaluated at the entries of x using the
%   stable three-term recurrence. The output has the SAME SHAPE as x.
%
%   INPUT
%     n  (1×1)  Degree n ≥ 0.
%     x  (vector)  Real evaluation points (typically in [-1,1]).
%
%   OUTPUT
%     Pn (same size as x)  Values of P_n at the given points.
%
%   Example:
%     x  = linspace(-1,1,5).';
%     P3 = directcollocation.legeval(3, x);   % returns a 5×1 column
%
%   Copyright (c) Your Name. All rights reserved.

    arguments
        n (1,1) double {mustBeInteger, mustBeNonnegative}
        x {mustBeVector, mustBeReal, mustBeFinite}
    end

    % Work in column form; restore original shape at the end.
    xcol = x(:);
    m = numel(xcol);

    if n == 0
        Pncol = ones(m,1);
        Pn = reshape(Pncol, size(x));
        return
    end

    if n == 1
        Pncol = xcol;
        Pn = reshape(Pncol, size(x));
        return
    end

    % ---- Three-term recurrence -------------------------------------------
    % P0(x) = 1,  P1(x) = x
    Pkm1 = ones(m,1);     % P0
    Pk   = xcol;          % P1

    for k = 1:n-1
        a = (2*k + 1) / (k + 1);
        b = k / (k + 1);
        Pk1 = a .* (xcol .* Pk) - b .* Pkm1;
        Pkm1 = Pk;
        Pk   = Pk1;
    end

    Pncol = Pk;
    Pn = reshape(Pncol, size(x));   % match input orientation
end
