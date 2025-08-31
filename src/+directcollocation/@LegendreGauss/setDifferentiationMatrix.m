function setDifferentiationMatrix(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss
    end

    % Square barycentric differentiation matrix on the collocation set
    T = obj.Mesh;                          % 1×N
    w = obj.BarycentricWeights;            % 1×N (from baryfit over T)

    D = directcollocation.baryder(w, T, T);% N×N, ℓ'_j evaluated at T(i)

    % Store as a CasADi constant to keep the graph small
    obj.DifferentiationMatrix = casadi.DM(D);
end
