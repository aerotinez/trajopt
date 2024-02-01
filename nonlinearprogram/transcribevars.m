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