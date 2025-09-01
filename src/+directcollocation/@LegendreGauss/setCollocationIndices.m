function setCollocationIndices(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss;
    end
    obj.CollocationIndices = 2:obj.NumNodes - 1;
end