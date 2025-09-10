function setTime(obj)
    arguments
        obj (1,1) trajopt.collocation.Program;
    end

    if obj.IsInitialTimeFree
        t0 = obj.Solution.value(obj.InitialTime);
    else
        t0 = obj.InitialTime;
    end

    if obj.IsFinalTimeFree
        tf = obj.Solution.value(obj.FinalTime);
    else
        tf = obj.FinalTime;
    end

    obj.Time = t0 + (tf - t0).*obj.Mesh;
end