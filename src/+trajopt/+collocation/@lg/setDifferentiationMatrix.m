function setDifferentiationMatrix(obj)
    arguments
        obj (1,1) trajopt.collocation.lg
    end
    D = trajopt.barydiff(obj.Nodes(1:end-1));
    obj.DifferentiationMatrix = D(:,2:end);
end
