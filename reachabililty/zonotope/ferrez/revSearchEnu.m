function s = revSearchEnu(s0,G)
    arguments
        s0 (1,:) double {mustBeMember(s0,[-1,1])};
        G double {validateInputs(s0,G)};
    end
    s = s0;
    wr = adjacencyOracle(s0,G);
    S = flipCells(s0);
    if isempty(S)
        return
    end
    for k = 1:size(S,1)
        w = adjacencyOracle(S(k,:),G);
        if all(isnan(w))
            continue
        end
        if ~isequal(parentSearch(G,ray(wr,w),S(k,:)),s0)
            return
        end
        s = revSearchEnu(S(k,:),G);
    end
end

function validateInputs(s0,G)
    if size(G,2) ~= numel(s0)
        error("Mismatching dimensions between s0 and G");
    end
end

function S = flipCells(s)
    m = numel(s);
    ind = s ~= -1;
    idx = 1:m;
    idx = idx(ind);
    n = sum(ind);
    S = repmat(s,[n,1]);
    for k = 1:n
        S(k,idx(k)) = -1;
    end
end

function w = adjacencyOracle(s,G)
    [n,m] = size(G);

    f = [
    -1;
    zeros(n,1)
    ].';

    A = [
        ones(m,1),-diag(s)*G.';
        1,zeros(1,n)
        ];
    
    b = [
        -diag(s)*ones(m,1);
        1
        ];
    
    opts = optimoptions('linprog','Display','none');
    [x,~,flag,~] = linprog(f,A,b,[],[],[],[],opts);

    if flag ~= 1
        w = nan(n,1);
        return
    end

    w = x(2:end);
end

function l = ray(p0,pf)
    arguments
        p0 (:,1) double;
        pf (:,1) double;
    end
    l = struct('p0',p0,'d',pf - p0);
end

function p = intersect(g,l)
    t = (-l.p0.'*g)./(l.d.'*g);
    p = l.p0 + l.d.*t;
end

function s = parentSearch(G,l,s)
    f = @(g)intersect(g,l);
    P = cell2mat(cellfun(f,num2cell(G,1),"uniform",0));
    pf = l.d + l.p0;
    [~,k] = min(vecnorm(pf - P,2,1));
    s(k) = -s(k);
end
