function setFinalTime(obj,final_time)
    arguments
        obj (1,1) directcollocation.Program;
        final_time (1,1) double = nan;
    end
    obj.IsFinalTimeFree = false;

    if isnan(final_time)
        final_time = obj.Problem.variable(1);
        obj.IsFinalTimeFree = true;
    end

    obj.FinalTime = final_time;

    if obj.IsFinalTimeFree
        obj.Problem.subject_to(obj.FinalTime >= obj.InitialTime + 1E-06);
    end
end