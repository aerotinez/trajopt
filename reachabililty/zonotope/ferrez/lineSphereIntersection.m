function [pa,pb] = lineSphereIntersection(l)
    arguments
        l (1,1) Line;
    end
    a = l.d.'*l.d;
    b = 2*l.d.'*l.p0;
    c = l.p0.'*l.p0 - 1;
    delta = b^2 - 4*a*c;
    ta = -b/(2*a) + sqrt(delta)/(2*a);
    tb = -b/(2*a) - sqrt(delta)/(2*a);
    pa = l.point(ta);
    pb = l.point(tb);
end

