function defect(obj)
    arguments
        obj (1,1) trajopt.collocation.hs
    end

    N = obj.NumNodes;
    idx0 = 1:2:N - 1;
    idxm = 2:2:N - 1;
    idxf = 3:2:N;

    dt = (obj.Mesh(idxf) - obj.Mesh(idx0))*(obj.FinalTime - obj.InitialTime);
    DT = repmat(dt,obj.NumStates,1);

    X = obj.States;
    U = obj.Controls;
    P = obj.Parameters;
    F = obj.Plant;

    F0 = F(X(:,idx0),U(:,idx0),P(:,idx0));
    Fm = F(X(:,idxm),U(:,idxm),P(:,idxm));
    Ff = F(X(:,idxf),U(:,idxf),P(:,idxf));

    obj.Problem.subject_to(X(:,idxf) - X(:,idx0) == DT.*(F0 + 4*Fm + Ff)/6);
    obj.Problem.subject_to(X(:,idxm) == (X(:,idx0) + X(:,idxf))/2 + DT.*(F0 - Ff)/8);
end
