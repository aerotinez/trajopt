function solve(obj)
    arguments
        obj (1,1) trajopt.collocation.LegendrePseudospectral
    end
    obj.Problem.solver('ipopt');
    setCollocationIndices(obj);
    setNodes(obj);
    setQuadratureWeights(obj);
    setDifferentiationMatrix(obj);
    defect(obj);
    cost(obj);
    obj.Solution = obj.Problem.solve();
    setMesh(obj);
    setTime(obj);
end
