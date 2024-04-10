function R = girard2005Alg(X0,A,b,t,m)
    arguments
        X0 (1,1) zonotope;
        A double {mustBeReal};
        b (1,1) double {mustBeReal,mustBePositive};
        t (1,:) double {mustBeReal};
        m (1,1) double {mustBeReal,mustBePositive} = 10;
    end
    ts = diff(t(1:2));
    f = str2func(class(X0));
    fhc = @(r)f(r.*eye(size(A,1)));
    An = norm(A,inf);
    ar = (exp(ts*An) - 1 - ts*An)*max(vecnorm(X0.generate(),inf,1));
    br = (exp(ts*An) - 1)*b/An;
    a = expm(ts.*A);

    c = (X0.Center + a*X0.Center)./2;

    g = 0.5.*[
        (X0.Generators + a*X0.Generators).';
        (X0.Center - a*X0.Center).';
        (X0.Generators - a*X0.Generators).'
        ].';

    Q = f(g,c) + fhc(ar + br);
    R = cell(numel(t),1);
    R{1} = Q;

    for i = 1:numel(t) - 1
        Q = reduceOrder(a*Q + fhc(br),m);
        R{i + 1} = Q;
    end
    R = [R{:}];
end

function zout = reduceOrder(zin,order)
    if zin.Order <= order
        zout = zin;
        return;
    end
    gk = vecnorm(zin.Generators,1,1) - vecnorm(zin.Generators,inf,1);
    k = [1,0]*sortrows([1:size(gk,2);gk].',2).';
    g = zin.Generators(:,k);
    n = zin.Dimension;
    h = diag(sum(abs(g(:,1:2*n)),2));
    f = str2func(class(zin));
    zout = f([h,g(:,2*n + 1:end)],zin.Center);
end