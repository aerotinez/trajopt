function setQuadratureWeights(obj)
    arguments
        obj (1,1) trajopt.collocation.lg
    end
    [~,w] = trajopt.lgquad(obj.NumNodes - 2);
    obj.QuadratureWeights = w.';
end
