function defect(obj)
    arguments
        obj (1,1) trajopt.collocation.lgr;
    end

    w = obj.QuadratureWeights; 
    t0 = obj.InitialTime;
    tf = obj.FinalTime;

    X = obj.States;
    XLGR = obj.States(:,obj.CollocationIndices);
    U = obj.Controls;
    P = obj.Parameters;

    D = obj.DifferentiationMatrix;
    F = obj.Plant(XLGR,U,P);
    obj.Problem.subject_to(((tf - t0)./2)*F - X*D == 0);

    X0 = X(:,1);
    Xf = X(:,end);
    
    if obj.IncludedEndPoint == -1
        obj.Problem.subject_to( Xf == X0 + ((tf - t0)./2)*F*w.');
    else
        obj.Problem.subject_to( X0 == Xf - ((tf - t0)./2)*F*w.');
    end
end