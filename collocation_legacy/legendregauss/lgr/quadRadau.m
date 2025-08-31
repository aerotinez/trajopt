function [w,x] = quadRadau(n)
    arguments
        n (1,1) {mustBeInteger,mustBePositive}
    end
    x = legendrePoints(n);
    P = legpol(n - 1)*x(2:end).^(fliplr(0:n-1).');
    w = [2/n^2,(1 - x(2:end))./(n^2.*(P).^2)];
end

function x = legendrePoints(n)
    pa = legpol(n);
    pb = legpol(n-1);
    num = pa + [0,pb];
    den = [1,1];
    [y,~] = deconv(num,den);
    x = [-1,sort(roots(y)).'];
end