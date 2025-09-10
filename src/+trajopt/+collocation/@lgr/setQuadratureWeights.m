function setQuadratureWeights(obj)
    arguments
        obj (1,1) trajopt.collocation.lgr
    end
    [~,w] = trajopt.lgrquad(obj.NumNodes - 1,obj.IncludedEndPoint);
    obj.QuadratureWeights = w(:).';
end
