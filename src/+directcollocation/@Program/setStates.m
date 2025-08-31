function setStates(obj,states)
    arguments
        obj (1,1) directcollocation.Program;
        states table;
    end
    obj.NumStates = height(states);
    obj.States = obj.Problem.variable(obj.NumStates,obj.NumNodes);
    setVariable(obj,obj.States,states);

    obj.IsInitialStateFree = true(obj.NumStates,1);
    obj.IsFinalStateFree = true(obj.NumStates,1);

    for state_idx = 1:obj.NumStates
        x0 = states(state_idx,:).InitialValue;
        xf = states(state_idx,:).FinalValue;
        if ~isnan(x0)
            obj.Problem.subject_to(obj.States(state_idx,1) == x0);
            obj.IsInitialStateFree(state_idx) = false;
        end
        if ~isnan(xf)
            obj.Problem.subject_to(obj.States(state_idx,obj.NumNodes) == xf);
            obj.IsFinalStateFree(state_idx) = false;
        end
    end
end