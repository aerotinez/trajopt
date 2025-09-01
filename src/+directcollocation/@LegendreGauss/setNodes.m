function setNodes(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss
    end

    % NumNodes = N + 2  ->  N interior Gauss collocation points
    N = obj.NumNodes - 2;

    if N == 1
        xg = 0;  % the single Gauss node
    else
        % Golub–Welsch for Gauss–Legendre nodes on (-1,1)
        k  = 1:(N-1);
        b  = k ./ sqrt(4*k.^2 - 1);               % off-diagonals of Jacobi matrix
        J  = diag(b,1) + diag(b,-1);              % symmetric tridiagonal
        J  = (J + J.')/2;                          % guard symmetry numerically
        [~,D] = eig(J);
        xg = sort(diag(D)).';                      % row vector, ascending
    end

    % Augmented node set used in the papers: [-1, tau_G, +1]
    obj.Nodes = [-1, xg, 1];
end
