function result = run(obj)
    arguments
        obj (1,1) SharpMotorcycleExtendedExperiment;
    end
    obj.Program.solve();
    result = obj.packageResult();
end