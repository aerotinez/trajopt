function c = legpol(n)
%LEGPOL Coefficients of the nth Legendre polynomial P_n(x).
%   c = LEGPOL(n) returns a 1-by-(n+1) row vector of coefficients for P_n(x), 
%   ordered for polyval (highest power first).
%
%   Examples:
%     >> legendre_poly_coeffs(0)    % 1
%     ans = 1
%
%     >> legendre_poly_coeffs(1)    % x
%     ans = [1 0]
%
%     >> legendre_poly_coeffs(2)    % (3x^2-1)/2
%     ans = [1.5 0 -0.5]
%
%     % evaluate P_5 at x=0.3
%     >> polyval(legendre_poly_coeffs(5), 0.3)

    arguments
        n (1,1) double {mustBeInteger, mustBeNonnegative};
    end

    % Base cases
    if n == 0
        c = 1;            % P0(x) = 1
        return
    elseif n == 1
        c = [1 0];        % P1(x) = x
        return
    end

    % Recurrence:
    % (k+1) P_{k+1} = (2k+1) x P_k - k P_{k-1}
    Pkm1 = 1;            % P0
    Pk   = [1 0];        % P1

    for k = 1:n-1
        a = (2*k + 1) / (k + 1);
        b = k / (k + 1);

        % Multiply by x: append a trailing zero (descending-power convention)
        xPk = [Pk 0];              % degree k+1
        % Pad P_{k-1} up to degree k+1: add two leading zeros
        Pkm1_pad = [0 0 Pkm1];     % degree k+1

        Pk1 = a * xPk - b * Pkm1_pad;

        Pkm1 = Pk;
        Pk   = Pk1;
    end

    c = Pk;
end
