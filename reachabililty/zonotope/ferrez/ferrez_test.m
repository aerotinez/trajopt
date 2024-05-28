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

% G = eye(3);


n = size(G,1);
m = size(G,2);

P = cellfun(@Plane,num2cell(G,1));

Pc = Plane(G(:,end)).translate([0;0;0]);
c = 'boypgcr';

L = arrayfun(@(P)intersect(Pc,P),P(1:end - 1));

% fig_3d = sphereFigure();
% arrayfun(@(P)plot(P,'b',0.25),P);
% plot(Pc,"#ffffff",1); 
% arrayfun(@(L)plot(L),L);
% view(-Pc.n);

fig_2d = cellFigure();
R = frameFromNormal(Pc.n);
L = unique(arrayfun(@(L)Line(R*L.p0,R*L.d),L));
arrayfun(@(L)plot(L),L);