function xd = diffToDot(obj,x,dstr)
    arguments
        obj (1,1) PrettyEquations;
        x (1,1) sym;
        dstr (1,1) string;
    end
    xs = char(x);

    if ~contains(xs,'_')
        xd = str2sym(xs + "_" + dstr);
        return
    end

    inds = strfind(xs,'_');
    xd = str2sym(xs(1:inds(1) - 1) + "_" + dstr + xs(inds(1):end));
end