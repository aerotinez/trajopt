function R = frameFromNormal(n)
    arguments
        n (3,1) double;
    end
    if norm(n) ~= 1
        n = normCols(n);
    end
    ez = n;
    ex = normCols(cross(ez,ez + [1;0;0]));
    ey = normCols(cross(ez,ex));
    R = [ex,ey,ez];
end