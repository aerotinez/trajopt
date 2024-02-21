function C = lagpol(t)
    arguments
        t (1,:) double {mustBeReal};
    end
    n = numel(t) - 1;
    A = (t.').^(0:n);
    C = (A\eye(n + 1)).';
end