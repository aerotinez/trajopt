function w = witness(G,s)
    arguments
        G double;
        s (1,:) double {mustBeMember(s,[-1,1])};
    end

    [n,m] = size(G);

    if numel(s) ~= m
        error("The size of s must be equal to the number of columns of G.")
    end

    f = [
        -1;
        zeros(n,1);
        ];
            
    A = [
        ones(m,1),-diag(s)*G.';
        1,zeros(1,n);
        ];

    b = [
        -diag(s)*ones(m,1);
        1;
        ];
            
    opts = optimoptions('linprog','Display','none');
    [x,~,flag,~] = linprog(f,A,b,[],[],[],[],opts);

    if flag ~= 1 || x(1) < 0
        w = nan(n,1);
        return
    end 
    w = x(2:end);
end