function setMesh(obj)
    arguments
        obj (1,1) directcollocation.Trapezoidal;
    end
    obj.Mesh = linspace(0,1,obj.NumNodes);
end