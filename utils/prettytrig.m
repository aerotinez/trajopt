function [pexpr,vars] = prettytrig(expr)
    arguments
        expr sym;
    end
    x = [findSymType(expr,"symfun"),symvar(expr)];
    x(x == sym('t')) = [];
    sx = arrayfun(@sin,x);
    cx = arrayfun(@cos,x);
    fx = @(f,x)str2sym(f + "_" + string(x));
    sx0 = arrayfun(@(x)fx('s',x),prettify(x));
    cx0 = arrayfun(@(x)fx('c',x),prettify(x));
    ovars = [sx,cx];
    vars = [sx0,cx0];
    pexpr = subs(expr,ovars,vars);
end