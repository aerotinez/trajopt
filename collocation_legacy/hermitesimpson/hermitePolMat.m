function H = hermitePolMat(x,n)
% hermitePolMat: Hermite polynomial matrix
    arguments
        x (1,1);
        n (1,1) double {mustBePositive, mustBeInteger};
    end
%   If:
%   
%   y(x) = a_0 + a_1*x + a_2*x^2 + ... + a_n*x^n
%
%   and:
%   
%   dy(x)/dx = a_1 + 2*a_2*x + ... + n*a_n*x^(n-1)
%   
%   then the Hermite polynomial matrix H is defined by:
%
%   H = [
%       1 x x^2 x^3 ... x^n
%       0 1 2*x 3*x^2 ... n*x^(n-1)
%       0 0 2 6*x ... n*(n-1)*x^(n-2)
%       ...
%       0 0 0 0 ... n!
%       ]
%
%   such that y(x) = H*a where a = [a_0 a_1 ... a_n].'
%
    [X,Y] = meshgrid(0:n - 1);
    m = (X - Y);
    A = cumprod([ones(1,n);m(1:n - 1, :)],1);
    idx = triu(repmat(0:n - 1,[n,1]) - (0:n - 1).');
    T = x.^idx;
    H = A.*T;
end