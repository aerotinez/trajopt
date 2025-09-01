function setDifferentiationMatrix(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss
    end

    % NumNodes = N + 2  ->  N Gauss collocation points
    N = obj.NumNodes - 2;
    assert(N >= 1, 'LegendreGauss requires at least 1 collocation point.');

    % Augmented state node set used for derivative evaluation at Gauss nodes:
    % x = [ -1, tau_1, ..., tau_N ]  (exclude the final +1)
    x = obj.Nodes(1:end-1);          % 1 × (N+1)

    % First-form barycentric weights on x
    c = ones(1, numel(x));
    for j = 1:numel(x)
        diffj = x(j) - x;
        diffj(j) = 1;                % skip self to avoid zero
        c(j) = 1 / prod(diffj);
    end

    % D(j,i) = ℓ'_j(x_i) with i = Gauss node index in x (i = 2..N+1)
    % Size: (N+1) × N  (rows = nodes in x, cols = Gauss eval points)
    D = zeros(N+1, N);
    for i = 1:N
        k = i + 1;                   % evaluation at Gauss node x(k)
        for j = 1:(N+1)
            if j ~= k
                % IMPORTANT: (x(k) - x(j))  -> correct sign
                D(j, i) = (c(j) / c(k)) * 1 / (x(k) - x(j));
            end
        end
        % diagonal so that column sum is zero (derivative of constant = 0)
        D(k, i) = -sum(D([1:k-1, k+1:end], i));
    end

    obj.DifferentiationMatrix = D;
end
