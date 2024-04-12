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
        Q = box(a*Q + fhc(br),m);
        R{i + 1} = Q;
    end
    R = [R{:}];
end