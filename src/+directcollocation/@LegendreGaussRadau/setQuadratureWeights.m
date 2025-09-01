function setQuadratureWeights(obj)
    arguments
        obj (1,1) directcollocation.LegendreGaussRadau
    end

    % Number of collocation nodes (Radau)
    Nc = obj.NumNodes - 1;
    assert(Nc >= 1, 'LegendreGaussRadau requires at least 1 collocation point.');

    % Convenience
    nodes = obj.Nodes(:).';                 % [-1, interior..., +1], ascending

    if Nc == 1
        % Only the included endpoint is collocated; its weight is the whole integral.
        w = 2;                              % row vector 1×1
        obj.QuadratureWeights = w;
        return
    end

    % Interior Radau nodes reside between the endpoints
    interior = nodes(2:end-1);              % 1×(Nc-1)
    PNm1 = legendreP(Nc-1, interior);       % P_{Nc-1}(x_i) at interior nodes

    if obj.IncludedEndPoint == -1
        % Collocation nodes: [-1, interior]
        w0 = 2 / (Nc^2);
        wi = (1 - interior) ./ (Nc^2 * (PNm1.^2));
        w  = [w0, wi];
    else
        % Collocation nodes: [interior, +1]
        wi = (1 + interior) ./ (Nc^2 * (PNm1.^2));
        wN = 2 / (Nc^2);
        w  = [wi, wN];
    end

    obj.QuadratureWeights = w;              % 1×Nc (row), aligns with CollocationIndices
end

% ---- local helper ----
function P = legendreP(n, x)
% Evaluate Legendre P_n(x) via three-term recurrence
    x = x(:).';
    if n == 0
        P = ones(size(x));
        return
    end
    Pm1 = ones(size(x));    % P0
    P   = x;                % P1
    if n > 1
        for k = 1:n-1
            Pp1 = ((2*k+1)*x.*P - k*Pm1)/(k+1);
            Pm1 = P; P = Pp1;
        end
    end
end
