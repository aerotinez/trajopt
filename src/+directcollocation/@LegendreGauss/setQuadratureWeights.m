function setQuadratureWeights(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss
    end

    % NumNodes = N + 2 (endpoints plus N interior Gauss points)
    N = obj.NumNodes - 2;
    assert(N >= 1, 'LegendreGauss requires at least 1 collocation point.');

    % Golub–Welsch: Gauss–Legendre weights for N interior nodes
    k = 1:(N-1);
    b = k ./ sqrt(4*k.^2 - 1);           % recurrence off-diagonals
    J = diag(b,1) + diag(b,-1);          % symmetric tridiagonal (N×N)
    [V,D] = eig(J);
    [~, idx] = sort(diag(D));            % sort nodes ascending (match setNodes)
    V = V(:, idx);

    w = 2 * (V(1,:).^2);                 % 1×N Gauss weights

    obj.QuadratureWeights = w;           % row vector, aligns with XLG columns
end
