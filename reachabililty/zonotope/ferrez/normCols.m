function vn = normCols(v)
    arguments
        v (3,:) double;
    end
    vn = v./vecnorm(v,2,1);
end