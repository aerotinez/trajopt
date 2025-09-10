function solve(obj)
    arguments
        obj (1,1) trajopt.collocation.LegendrePseudospectral
    end
    obj.Problem.solver('ipopt');
    defect(obj);
    cost(obj);
    obj.Solution = obj.Problem.solve();
    setTime(obj);
end
