function setDifferentiationMatrix(obj)
    arguments
        obj (1,1) trajopt.collocation.lgr
    end
    D = trajopt.barydiff(obj.Nodes);
    obj.DifferentiationMatrix = D(:,obj.CollocationIndices);
end
