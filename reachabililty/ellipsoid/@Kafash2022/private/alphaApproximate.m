function Ea = alphaApproximate(obj,E,F,alpha)
    arguments
        obj (1,1) Kafash2022;
        E (1,1) ellipsoid;
        F double;
        alpha (1,1) double;
    end
    P = E.Q;
    res = F*(P\eye(size(P)))*F.';
    I = eye(size(res));
    Ea = ellipsoid((res + alpha^2*I)\I);
end