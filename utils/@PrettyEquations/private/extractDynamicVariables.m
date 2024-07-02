function q = extractDynamicVariables(obj)
    arguments
        obj (1,1) PrettyEquations;
    end
    q = findSymType(obj.eq_in,"symfunOf",sym('t')).';
end