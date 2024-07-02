function p = extractParameters(obj)
    arguments
        obj (1,1) PrettyEquations
    end
    p = symvar(obj.eq_in).';
    if sum(has(p,sym('t')))
        p(has(p,sym('t'))) = [];
    end
end