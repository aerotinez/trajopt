function tf = isfeasible(S,G)
    arguments
        S double;
        G double;
    end
    A = [
        -S;
        setdiff(G,S,"rows");
    ];

    b = -ones(size(A,1),1);

    f = zeros(size(A,2),1);

    opts = optimset("Display","off");
    [~,~,exitflag,~] = linprog(f,A,b,[],[],[],[],[],opts);
    tf = exitflag == 1;
end