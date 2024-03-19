function [w,x] = quadLegendreGauss(n)
    arguments
        n (1,1) {mustBeInteger,mustBePositive}
    end
    x = sort(roots(legpol(n))).';
    P = legpol(n + 1)*x.^(fliplr(0:n + 1).');
    w = (2.*(1 - x.^2))./(((n+1).^2).*(P.^2));
end