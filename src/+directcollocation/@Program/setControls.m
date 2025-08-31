function setControls(obj,controls)
    arguments
        obj (1,1) directcollocation.Program;
        controls table;
    end
    obj.NumControls = height(controls);
    obj.Controls = obj.Problem.variable(obj.NumControls,obj.NumNodes);
    setVariable(obj,obj.Controls,controls);
end