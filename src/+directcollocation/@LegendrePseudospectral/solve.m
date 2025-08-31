function solve(obj)
    arguments
        obj (1,1) directcollocation.LegendrePseudospectral
    end

    obj.Problem.solver('ipopt');

    setMesh(obj);                   % sets Mesh (nodes)
    setQuadratureWeights(obj);      % sets QuadratureWeights for the scheme
    obj.NumIntervals = numel(obj.Mesh) - 1;

    setBarycentricWeights(obj);     % directcollocation.baryfit over Mesh
    setDifferentiationMatrix(obj);  % barycentric D over Mesh

    defect(obj);
    cost(obj);
    obj.Solution = obj.Problem.solve();
end
