function setCollocationIndices(obj)
    arguments
        obj (1,1) trajopt.collocation.lg;
    end
    obj.CollocationIndices = 2:obj.NumNodes - 1;
end