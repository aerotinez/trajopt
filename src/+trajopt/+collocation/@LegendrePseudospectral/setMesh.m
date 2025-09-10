function setMesh(obj)
    arguments
        obj (1,1) trajopt.collocation.LegendrePseudospectral
    end
    obj.Mesh = (obj.Nodes + 1)/2;
end
