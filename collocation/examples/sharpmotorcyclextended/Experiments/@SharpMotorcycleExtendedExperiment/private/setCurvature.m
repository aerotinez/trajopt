function k = setCurvature(obj)
    arguments
        obj (1,1) SharpMotorcycleExtendedExperiment;
    end
    N = obj.Problem.NumNodes - 2;
    tau = 0.5.*([-1,sort(roots(legpol(N))).',1] + 1);
    arclength = obj.Scenario.Parameter./obj.Scenario.Parameter(end);
    k = interp1(arclength,obj.Scenario.Curvature,tau);
end