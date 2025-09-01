function solve(obj)
    arguments
        obj (1,1) directcollocation.LegendrePseudospectral
    end

    obj.Problem.solver('ipopt');

    setCollocationIndices(obj);
    setNodes(obj);
    setMesh(obj);
    setQuadratureWeights(obj);
    setDifferentiationMatrix(obj);

    defect(obj);
    cost(obj);
    obj.Solution = obj.Problem.solve();
end
