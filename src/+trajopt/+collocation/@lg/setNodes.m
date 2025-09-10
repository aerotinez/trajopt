function setNodes(obj)
    arguments
        obj (1,1) trajopt.collocation.lg
    end
    [xg,~] = trajopt.lgquad(obj.NumNodes - 2);
    obj.Nodes = [-1,xg(:)',1];
end
