function setCollocationIndices(obj)
    arguments
        obj (1,1) directcollocation.LegendreGaussRadau;
    end
    if obj.IncludedEndPoint == 1
        obj.CollocationIndices = 2:obj.NumNodes;
    else
        obj.CollocationIndices = 1:obj.NumNodes - 1;
    end
end