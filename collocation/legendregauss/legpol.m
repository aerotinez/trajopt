function c = legpol(n)
    arguments
        n (1,1) double {mustBeInteger,mustBeNonnegative}
    end
    bc = @nchoosek;
    f = @(n,k)(1/(2^n))*((-1)^k)*bc(n,k)*bc(2*(n - k),n);
    g = @(n)arrayfun(@(k)f(n,k),0:floor(n/2));
    a = fliplr(g(n));
    if n < 1
        c = a;
        return
    end
    if logical(mod(n,2))
        c = fliplr(upsample(a,2,1));
        if iscolumn(c)
            c = fliplr(c.');
        end
        return
    end
    b = upsample(a,2);
    c = fliplr(b(1:end - 1));
end