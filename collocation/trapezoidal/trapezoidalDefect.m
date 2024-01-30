function Ceq = trapezoidalDefect(dynamics,x0,u0,xf,uf,h)
    arguments
        dynamics (1,1) Plant;
        x0;
        u0;
        xf;
        uf;
        h;
    end
    f = dynamics.Dynamics;
    f0 = f(x0,u0);
    ff = f(xf,uf);
    Ceq = xf - x0 - (h/2).*(f0 + ff);
end