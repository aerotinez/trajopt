function out = iscollinear(va,vb,tol)
    arguments
        va (:,1) double;
        vb (:,1) double;
        tol (1,1) double = eps;
    end
    out = abs(1 - va.'*vb./(norm(va)*norm(vb))) <= tol;
end