function setInitialTime(obj,initial_time)
    arguments
        obj (1,1) trajopt.collocation.Program;
        initial_time (1,1) double = nan;
    end
    obj.IsInitialTimeFree = false;
    if isnan(initial_time)
        initial_time = obj.Problem.variable(1);
        obj.IsInitialTimeFree = true;
    end
    obj.InitialTime = initial_time;
end