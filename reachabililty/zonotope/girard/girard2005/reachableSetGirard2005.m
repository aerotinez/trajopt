function R = reachableSetGirard2005(X0,A,b,t)
    arguments
        X0 (1,1) zonotope;
        A double {mustBeReal};
        b (1,1) double {mustBeReal,mustBePositive};
        t (1,:) double {mustBeReal};
    end
    ns = numel(t);
    ts = t(end)/ns;
    fhc = @(r)zonotope(r.*eye(size(A,1)));
    An = norm(A,inf);
    ar = (exp(ts*An) - 1 - ts*An)*max(vecnorm(X0.generate(),inf,1));
    br = exp(ts*An - 1)*b/An;
    a = expm(ts.*A);
    c = (X0.Center + a*X0.Center)./2;
    g = (X0.Generators + a*X0.Generators)./2;
    f = str2func(class(X0));
    P = f(g,c);
    Q = P + fhc(ar + br);
    R = cell(ns,1);
    R{1} = Q;
    for i = 1:ns - 1
        P = a*P;
        Q = P + fhc(br);
        R{i + 1} = R{i} + Q;
    end
    R = [R{:}];
end