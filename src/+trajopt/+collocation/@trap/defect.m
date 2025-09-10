function defect(obj)
    arguments
        obj (1,1) trajopt.collocation.trap;
    end
    N = obj.NumIntervals;
    dt = diff(obj.Mesh)*(obj.FinalTime - obj.InitialTime);
    DT = repmat(dt,obj.NumStates,1);

    X = obj.States;
    U = obj.Controls;
    P = obj.Parameters;
    F = obj.Plant;
    F0 = F(X(:,1:N),U(:,1:N),P(:,1:N));
    Ff = F(X(:,2:end),U(:,2:end),P(:,2:end));

    obj.Problem.subject_to(X(:,2:end) - X(:,1:N) == DT.*(F0 + Ff)/2);
end