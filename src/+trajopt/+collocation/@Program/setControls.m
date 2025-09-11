function setControls(obj,controls)
    arguments
        obj (1,1) trajopt.collocation.Program;
        controls table;
    end
    obj.NumControls = height(controls);
    obj.Controls = obj.Problem.variable(obj.NumControls,obj.NumNodes);
    setVariable(obj,obj.Controls,controls);
    
    for control_idx = 1:obj.NumControls
        u0 = controls(control_idx,:).InitialValue;
        uf = controls(control_idx,:).FinalValue;
        if ~isnan(u0)
            obj.Problem.subject_to(obj.Controls(control_idx,1) == u0);
        end
        if ~isnan(uf)
            obj.Problem.subject_to(obj.Controls(control_idx,end) == uf);
        end
    end
end