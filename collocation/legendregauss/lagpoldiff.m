function dL = lagpoldiff(p,t)
    arguments
        p (1,:);
        t (1,:);
    end
    n = numel(p) - 1;
    A = (p.').^(0:n);
    dL = ((A\eye(n + 1)).')*((0:n).'.*[zeros(1,numel(t));t.^((0:n - 1).')]);
end