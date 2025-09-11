function setControls(obj,controls)
    arguments
        obj (1,1) trajopt.collocation.lgr;
        controls table;
    end
    obj.NumControls = height(controls);
    obj.Controls = obj.Problem.variable(obj.NumControls,obj.NumNodes - 1);
    setVariable(obj,obj.Controls,controls);

    for control_idx = 1:obj.NumControls
        if obj.IncludedEndPoint == 1
            u0 = controls(control_idx,:).InitialValue;
            if ~isnan(u0)
                obj.Problem.subject_to(obj.Controls(control_idx,1) == u0);
            end
        else
            uf = controls(control_idx,:).FinalValue;
            if ~isnan(uf)
                obj.Problem.subject_to(obj.Controls(control_idx,end) == uf);
            end
        end
    end
end