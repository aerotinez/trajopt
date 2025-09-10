function setNodes(obj)
    arguments
        obj (1,1) trajopt.collocation.lgr
    end

    N = obj.NumNodes - 1;
    
    if N == 1
        obj.Nodes = [-1,1];
        return
    end

    [t,~] = trajopt.lgrquad(N,obj.IncludedEndPoint);

    if obj.IncludedEndPoint == 1
        interior = t(1:end - 1);
    else
        interior = t(2:end);
    end

    obj.Nodes = [-1,interior.',1];
end
