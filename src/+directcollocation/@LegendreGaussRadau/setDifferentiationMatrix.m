% File: +directcollocation/@LegendreGaussRadau/setDifferentiationMatrix.m
function setDifferentiationMatrix(obj)
    arguments
        obj (1,1) directcollocation.LegendreGaussRadau
    end

    % State nodes (augmented): [-1, interior..., +1]
    x  = obj.Nodes(:).';                 % 1 × NumNodes
    Ns = numel(x);                       % NumNodes
    Nc = numel(obj.CollocationIndices);  % NumNodes - 1
    assert(Nc >= 1 && Ns == obj.NumNodes, 'Size mismatch in nodes/collocation.');

    % First-form barycentric weights on the state node set
    c = ones(1, Ns);
    for j = 1:Ns
        diffj = x(j) - x;
        diffj(j) = 1;                    % skip self
        c(j) = 1 / prod(diffj);
    end

    % Differentiation matrix: rows = all state nodes, cols = collocation nodes
    D = zeros(Ns, Nc);
    for i = 1:Nc
        k = obj.CollocationIndices(i);   % index in the state-node array
        for j = 1:Ns
            if j ~= k
                % IMPORTANT: (x(k) - x(j)) for correct sign
                D(j, i) = (c(j) / c(k)) * 1 / (x(k) - x(j));
            end
        end
        % diagonal so each column sums to zero (derivative of constant = 0)
        D(k, i) = -sum(D([1:k-1, k+1:end], i));
    end

    obj.DifferentiationMatrix = D;       % size: NumNodes × (NumNodes-1)
end
