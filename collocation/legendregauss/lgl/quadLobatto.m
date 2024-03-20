function [w,x] = quadLobatto(n)
    arguments
        n (1,1) {mustBeInteger,mustBePositive}
    end
    x = legendrePoints(n);
    w1 = 2/(n*(n - 1));
    P = legpol(n - 1)*x(2:end - 1).^(fliplr(0:n - 1).');
    w = [w1,2./(n*(n - 1).*P.^2),w1];
end

function x = legendrePoints(n)
    Pd = fliplr(1:n - 1).*(eye(n - 1,n)*legpol(n - 1).').';
    x = [-1,sort(roots(Pd)).',1];
end