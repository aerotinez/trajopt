function defect(obj)
    arguments
        obj (1,1) trajopt.collocation.lg;
    end

    w = obj.QuadratureWeights; 
    t0 = obj.InitialTime;
    tf = obj.FinalTime;

    X = obj.States;
    XLG = obj.States(:,obj.CollocationIndices);
    U = obj.Controls(:,obj.CollocationIndices);
    P = obj.Parameters(:,obj.CollocationIndices);

    D = obj.DifferentiationMatrix;
    F = obj.Plant(XLG,U,P);
    obj.Problem.subject_to(((tf - t0)./2)*F - X(:,1:end - 1)*D == 0);

    X0 = X(:,1);
    Xf = X(:,end);
    obj.Problem.subject_to(Xf == X0 + ((tf - t0)./2)*F*w');
end