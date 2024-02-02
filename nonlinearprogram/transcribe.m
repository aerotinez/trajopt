function prog = transcribe(f,prob,guess)
    arguments
        f (1,1) function_handle;
        prob (1,1) ocp;
        guess  (:,1) double;
    end
    variables = transcribevars(prob.Variables,guess);
    mesh = nlpmesh(linspace(0,1,variables.NumPoints));
    [Aeq,beq] = transcribeequalityconstraints(prob.Variables,variables);
    [lb,ub] = transcribebounds(prob.Variables,variables);
    cost = prob.CostFunction;
    constraints = prob.Constraints;
    prog = f(variables,mesh,cost,constraints,Aeq,beq,lb,ub);
end
function nlp_vars = transcribevars(ocp_vars,guess)
    arguments
        ocp_vars (1,1) ocpvars;
        guess (:,1) double;
    end
    x = ocp_vars;
    z = nlpvars();
    z.InitialTime = x.Variable.Initial;
    z.FinalTime = x.Variable.Final;
    z.NumStates = numel(x.State);
    z.NumControls = numel(x.Control);
    z.VariableName = [x.Variable.Name].';
    z.StateNames = [x.State.Name].';
    z.ControlNames = [x.Control.Name].';
    z.StateUnitName = [x.State.UnitName].';
    z.ControlUnitName = [x.Control.UnitName].';
    z.VariableUnit = [x.Variable.Units].';
    z.StateUnits = [x.State.Units].';
    z.ControlUnits = [x.Control.Units].';
    z.FreeInitialTime = isempty(x.Variable.Initial);
    z.FreeFinalTime = isempty(x.Variable.Final);
    z.set(guess);
    nlp_vars = z;
end
function [Aeq,beq] = transcribeequalityconstraints(ocp_vars,nlp_vars)
    x = ocp_vars;
    z = nlp_vars;
    nx = z.NumStates;
    nu = z.NumControls;
    x0 = [x.State.Initial].';
    xf = [x.State.Final].';
    N = z.NumPoints;
    Aeq = [];
    beq = [];
    if ~isempty(x0)
        Aeq = [eye(nx),zeros(nx,nu),zeros(nx,(nx + nu)*(N - 1))];
        beq = x0;
    end
    if ~isempty(xf)
        Aeq = [Aeq;zeros(nx,(nx + nu)*(N - 1)),eye(nx),zeros(nx,nu)];
        beq = [beq;xf];
    end
    if z.FreeFinalTime 
        Aeq = [zeros(size(Aeq,1),1),Aeq];
    end
    if z.FreeInitialTime 
        Aeq = [zeros(size(Aeq,1),1),Aeq];
    end 
end
function [lb,ub] = transcribebounds(ocp_vars,nlp_vars)
    x = ocp_vars;
    z = nlp_vars;
    N = z.NumPoints;
    y = [
        x.State;
        x.Control
        ];
    lb = reshape(repmat([y.LowerBound].',[1,N]),[],1);
    ub = reshape(repmat([y.UpperBound].',[1,N]),[],1);
    if z.FreeFinalTime
        lb = [
            x.Variable.LowerBound;
            lb
            ];
        ub = [
            x.Variable.UpperBound;
            ub
            ];
    end
    if z.FreeInitialTime
        lb = [
            x.Variable.LowerBound;
            lb
            ];
        ub = [
            x.Variable.UpperBound;
            ub
            ];
    end
end