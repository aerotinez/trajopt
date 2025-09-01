function setControls(obj,controls)
    arguments
        obj (1,1) directcollocation.LegendreGaussRadau;
        controls table;
    end
    obj.NumControls = height(controls);
    obj.Controls = obj.Problem.variable(obj.NumControls,obj.NumNodes - 1);
    setVariable(obj,obj.Controls,controls);
end