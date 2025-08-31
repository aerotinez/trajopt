function setStates(obj,states)
    arguments
        obj (1,1) directcollocation.LegendreGauss;
        states table;
    end
    obj.NumStates = height(states);
    obj.States = obj.Problem.variable(obj.NumStates,obj.NumNodes);
    setVariable(obj,obj.States,states);

    obj.IsInitialStateFree = true(obj.NumStates,1);
    obj.IsFinalStateFree = true(obj.NumStates,1);

    obj.StartStateVals = nan(obj.NumStates,1);
    obj.EndStateVals = nan(obj.NumStates,1);

    for state_idx = 1:obj.NumStates
        x0 = states(state_idx,:).InitialValue;
        xf = states(state_idx,:).FinalValue;
        if ~isnan(x0)
            obj.IsInitialStateFree(state_idx) = false;
            obj.StartStateVals(state_idx) = x0;
        end
        if ~isnan(xf)
            obj.IsFinalStateFree(state_idx) = false;
            obj.EndStateVals(state_idx) = xf;
        end
    end
end