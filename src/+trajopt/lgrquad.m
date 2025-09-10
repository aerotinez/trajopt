function [t,w] = lgrquad(N,included)
%LGRQUAD  Legendre–Gauss–Radau via Golub–Welsch on Gauss–Jacobi.
%   [t, w] = LGRQUAD(N)            % includes +1 (right Radau)
%   [t, w] = LGRQUAD(N, INCLUDED)  % INCLUDED ∈ {-1, +1} endpoint to include
%
%   Implementation:
%     - Interior nodes are the Gauss–Jacobi nodes for weight (1 - s*x),
%       where s = INCLUDED and (α,β) = (1,0) if s=+1, (0,1) if s=-1.
%     - We get these via Golub–Welsch using Jacobi recurrence coefficients.
%     - Convert Gauss–Jacobi weights ẃ_i to Radau weights:
%           w_i = ẃ_i / (1 - s*x_i),  i=1..N-1
%       and endpoint weight w_end = 2/N^2.
    arguments
        N (1,1) double {mustBeFinite,mustBePositive,mustBeInteger};
        included (1,1) double {mustBeMember(included,[-1,1])} = 1;
    end

    if N == 1
        t = included;
        w = 2;
        return
    end

    % --- Gauss–Jacobi parameters for weight (1 - s*x) ---
    if included == 1
        aJ = 1; 
        bJ = 0;              % right Radau (include +1)
    else
        aJ = 0; 
        bJ = 1;              % left  Radau (include -1)
    end

    % --- Jacobi recurrence coefficients (orthonormal) for size m=N-1 ---
    m = N - 1;
    k = (0:m-1).';

    % Use Jacobi A_n, B_n, C_n then set a = B_n, b_n = sqrt(A_{n-1} C_n)
    d = 2*k + aJ + bJ;
    A = 2*(k + 1).*(k + aJ + bJ + 1)./((d + 1).*(d + 2));
    B = (bJ^2 - aJ^2)./(d.*(d + 2));
    C = 2*(k+aJ).*(k + bJ)./(d.*(d + 1));

    a  = B;
    b = zeros(0,1);
    if m >= 2
        b  = sqrt(A(1:end - 1).*C(2:end));
    end

    % --- Gauss–Jacobi via Golub–Welsch (μ0 = ∫(1 - s*x)dx = 2) ---
    [x_int,w_hat] = trajopt.golubwelsch(a,b,2);

    % --- Convert to LGR weights and assemble nodes ---
    w_int = w_hat./(1 - included*x_int);

    if included == 1
        t = [
            x_int;
            1
            ];

        w = [
            w_int;  
            2/N^2
            ];
    else
        t = [
            -1;
            x_int
            ];

        w = [
            2/N^2;
            w_int
            ];
    end
end
