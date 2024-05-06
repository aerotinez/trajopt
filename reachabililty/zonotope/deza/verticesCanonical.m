function P = verticesCanonical(G)
    arguments
        G double;
    end
    n = size(G,2);
    m = size(G,1);
    P = zeros(1,n);
    La = double.empty(0,n);
    for k = 1:floor(m/2) - 1
        Lb = double.empty(0,n);
        idx = size(La,1);
        if idx == 0
            idx = 1;
        end
        for j = 1:idx
            if size(La,1) == 0
                S = La;
            else
                S = reshape(La(j,:),n,[]).';
            end
            g = setdiff(G,S,'rows');
            for i = 1:size(g,1)
                if isfeasible(union(S,g(i,:),"rows"),G)
                    Li = union(S,g(i,:),"rows");
                    Lb = [
                        Lb;
                        reshape(Li.',[],1).';
                    ];
                end
            end
        end
        Lb = unique(Lb,'rows');
        for j = 1:size(Lb,1)
            p = reshape(Lb(j,:),n,[]).';
            P = [
                P;
                sum(p,1)
            ];
        end
        La = Lb;
    end
end