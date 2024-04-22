function vfilt = filtercollinear(v,tol)
    arguments
        v double;
        tol (1,1) double = eps;
    end
    [n,m] = size(v);
    aligned = false(1,m);
    vfilt = zeros(n,m);
    for i = 1:m
        if aligned(i)
            continue
        end
        sumvec = v(:,i);
        for j = i + 1:m
            if iscollinear(v(:,i),v(:,j),tol)
                sumvec = sumvec + v(:,j);
                aligned(j) = true;
            end
        end
        vfilt(:,i) = sumvec;
    end
    vfilt = vfilt(:,~aligned);
end