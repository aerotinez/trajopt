close("all"); clear; clc;

s = (1 + sqrt(5))/2;
G = [
    1,0,-s;
    1,0,s;
    0,-s,1;
    0,s,1;
    -s,1,0;
    s,1,0;
    1,s,s-1;
    1,-s,s-1;
    1,-s,1-s;
    1,s,1-s;
    s,1-s,1;
    s,1-s,-1;
    s,s-1,-1;
    s,s-1,1;
    s-1,1,s;
    s-1,-1,-s;
    s-1,1,-s;
    s-1,-1,s;
    2,0,0;
    0,2,0;
    0,0,2
    ].';


n = size(G,1);
m = size(G,2);

P = cellfun(@Plane,num2cell(G,1));

Pc = Plane(G(:,end)).translate([0;0;0.25]);
c = 'boypgcr';

L = arrayfun(@(P)intersect(Pc,P),P(1:end - 1));

% fig_3d = sphereFigure();
% arrayfun(@(P)plot(P,'b',0.25),P);
% plot(Pc,"#ffffff",1); 
% arrayfun(@(L)plot(L),L);
% view(-Pc.n);

fig_2d = cellFigure();
R = frameFromNormal(Pc.n);
L = arrayfun(@(L)Line(R*L.p0,R*L.d),L);
arrayfun(@(L)plot(L),L);

rng(19);

z = L(1).p0(end);

p0 = [
    rand(2,1);
    z
    ];

pf = [
    1E-05*rand(2,1);
    z
    ];

r = Line(p0,pf - p0);

fpk = @(k)intersect(r,L(k));
pk = cell2mat(arrayfun(fpk,1:numel(L),"uniform",0));
[~,k] = min(vecnorm(pk - p0,2,1));

c = ones(k,1);
Gk = G(:,1:k);

f = [
    -1;
    zeros(n,1)
    ];

A = [
    -diag(c)*Gk.',diag(c)*ones(k,1);
    zeros(1,n),1
    ];

b = [
    -diag(c)*ones(k,1);
    1
    ];

lb = [
    -inf(n,1);
    0
    ];

options = optimoptions('linprog','Display','none');
[x,~,exitflag,~] = linprog(f,A,b,[],[],lb,[],options);

hold on;
scatter3(p0(1),p0(2),p0(3),'r',"filled");
scatter3(pf(1),pf(2),pf(3),'g',"filled");
hold off;

plot(r,mcolor('b'));