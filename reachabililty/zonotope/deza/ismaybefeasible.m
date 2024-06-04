function tf = ismaybefeasible(S,G)
    arguments
        S double;
        G double;
    end
    pS = sum(S,1);
    x = ismember(G,S,"rows").';
    X = nbinm(size(S,1),size(G,1));
    [val,k] = ismember(x,X,"rows");
    if val
        X(k,:) = [];
    end
    tf = true;
    if any(abs(vecnorm(pS - (G.'*X.').',2,2)) < 1E-03)
        tf = false;
    end
end