function setQuadratureWeights(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss
    end

    n = obj.NumNodes;

    if n == 1
        obj.QuadratureWeights = 1.0;           % sum=1 on [0,1]
        return
    end

    % map Mesh back to [-1,1] for the closed-form weight formula
    x = 2*obj.Mesh(:) - 1;                     % n×1

    % w_i (on [-1,1]): 2 / ((1 - x_i^2) * [P'_n(x_i)]^2)
    % use identity: (1 - x^2) P'_n = n * (x P_n - P_{n-1})
    Pn   = directcollocation.legeval(n,   x);
    Pnm1 = directcollocation.legeval(n-1, x);
    denom  = n^2 * (x .* Pn - Pnm1).^2;
    w_m11  = 2 * (1 - x.^2) ./ denom;         % sum = 2 on [-1,1]
    w01    = 0.5 * w_m11;                     % sum = 1 on [0,1]

    obj.QuadratureWeights = w01(:).';
end
