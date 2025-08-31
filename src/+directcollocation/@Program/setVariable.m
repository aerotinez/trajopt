function setVariable(obj,vars,vars_tab)
    arguments
        obj (1,1) directcollocation.Program;
        vars {mustBeA(vars,{'casadi.MX','casadi.OptiVariable'})};
        vars_tab table;
    end

    for var_idx = 1:size(vars,1)
        lb = vars_tab(var_idx,:).LowerBound;
        ub = vars_tab(var_idx,:).UpperBound;
        x0 = vars_tab(var_idx,:).InitialValue;
        xf = vars_tab(var_idx,:).FinalValue;
        var = vars(var_idx,:);

        if ~isnan(x0) && ~isnan(xf)
            x = linspace(x0,xf,obj.NumNodes);
        elseif ~isnan(x0) && isnan(xf)
            x = x0*ones(1,obj.NumNodes);
        elseif isnan(x0) && ~isnan(xf)
            x = xf*ones(1,obj.NumNodes);
        else
            x = zeros(1,obj.NumNodes);
        end

        obj.Problem.set_initial(var,x);

        if ~isinf(lb)
            obj.Problem.subject_to(var >= lb);
        end
        if ~isinf(ub)
            obj.Problem.subject_to(var <= ub);
        end
    end
end
