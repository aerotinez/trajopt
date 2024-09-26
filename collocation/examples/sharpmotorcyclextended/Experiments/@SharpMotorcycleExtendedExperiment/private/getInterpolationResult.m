function res = getInterpolationResult(obj)
    arguments
        obj (1,1) SharpMotorcycleExtendedExperiment;
    end
    s = obj.Program.interpolateTime();
    x = obj.Program.interpolateState(s);
    res = obj.getResult(s,x);
end