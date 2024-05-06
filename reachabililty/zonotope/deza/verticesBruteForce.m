function P = verticesBruteForce(G)
    arguments
        G double;
    end
    n = size(G,2);
    m = size(G,1);
    P = zeros(1,n);
    for i = 1:2^m - 1
        k = logical(dec2bin(i,m) - '0');
        if isfeasible(G(k,:),G)
            P = [
                P;
                sum(G(k,:),1)
                ];
        end
    end
end