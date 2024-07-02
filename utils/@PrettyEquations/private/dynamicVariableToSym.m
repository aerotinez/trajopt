function qs = dynamicVariableToSym(obj)
    arguments
        obj (1,1) PrettyEquations
    end
    f = @(x)str2sym(strrep(string(x),'(t)',''));
    qs = arrayfun(f,obj.q_in);
end