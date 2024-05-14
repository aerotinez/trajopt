function v = minkowskiVertices(G)
    arguments
        G double;
    end
    f = @(g)[zeros(size(g)),g];
    g = cellfun(f,num2cell(G,1),"uniform",false);
    v = minkowskiSum(g{:});
end