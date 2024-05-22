function R = frameFromNormal(n)
    arguments
        n (3,1) double;
    end
    if norm(n) ~= 1
        n = normCols(n);
    end
    ez = [0;0;1];
    if isequal(n,ez)
        R = eye(3);
        return;
    end
    axe = normCols(cross(n,ez));
    ang = acos(n.'*ez);
    R = axang2rotm([axe;ang].'); 
end