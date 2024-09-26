function res = getCollocationResult(obj)
    arguments
        obj (1,1) SharpMotorcycleExtendedExperiment;
    end
    s = obj.Program.Time;
    x = obj.Program.Plant.States.getValues();
    res = obj.getResult(s,x);
end