function setMesh(obj)
    arguments
        obj (1,1) trajopt.collocation.trap;
    end
    obj.Mesh = linspace(0,1,obj.NumNodes);
end