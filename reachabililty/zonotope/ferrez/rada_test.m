close("all"); clear; clc;

G = [
    1,1,1;
    1,-1,1;
    1,1,-1;
    1,-1,-1
    ].';

[n,m] = size(G);

s = ones(m,1);

rng(16);
N = 10;
wr = -N + 2*N*rand(n,1);

N0 = 1E-06;
w0 = -N0 + 2*N0*rand(n,1);

S = num2cell(flippedCells(s),1);
f = @(s)adjacencyOracle(G,s);
W = cellfun(f,S,"uniform",0);

fs = @(s,w)flipCell(s,firstPlaneHit(G,ray(wr,w)));
Sk = cellfun(fs,S,W,"uniform",0);

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

function k = firstPlaneHit(G,l)
    f = @(g)intersect(g,l);
    P = cell2mat(cellfun(f,num2cell(G,1),"uniform",0));
    pf = l.d + l.p0;
    [~,k] = min(vecnorm(pf - P,2,1));
end

function w = adjacencyOracle(G,s)
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

function S = flippedCells(s)
    m = numel(s);
    ind = s ~= -1;
    idx = 1:m;
    idx = idx(ind);
    S = repmat(s,[1,sum(ind)]);
    for k = 1:sum(ind)
        S(idx(k),k) = -1;
    end
end

function s = flipCell(s,k)
    s(k) = -s(k);
end