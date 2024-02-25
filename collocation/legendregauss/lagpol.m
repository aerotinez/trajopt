function L = lagpol(p,t)
    arguments
        p (1,:);
        t (1,:);
    end
    n = numel(p) - 1;
    A = (p.').^(0:n);
    L = ((A\eye(n + 1)).')*(t.^((0:n).'));
end