function solve(obj)
    arguments
        obj trajopt.collocation.Program;
    end
    setMesh(obj);
    obj.NumIntervals = numel(obj.Mesh) - 1;
    defect(obj);
    cost(obj);
    obj.Problem.solver('ipopt');
    obj.Solution = obj.Problem.solve();
    setTime(obj);
end