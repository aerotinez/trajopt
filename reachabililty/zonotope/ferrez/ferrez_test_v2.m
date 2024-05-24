close("all"); clear; clc;

G = [
    1,1,0;
    1,-1,0;
    1,0,1;
    1,0,-1;
    0,1,1;
    0,1,-1
    ].';
n = size(G,1);
m = size(G,2);

P = cellfun(@Plane,num2cell(G,1));
Pc = Plane(G(:,end)).translate([0;0;1]);
c = 'boypgcr';

fig_3d = sphereFigure();
arrayfun(@(P,c)plot(P,mcolor(c),0.5),P,c(1:m));
plot(Pc,"#ffffff",1);
L = arrayfun(@(P)intersect(Pc,P),P(1:end - 1));
arrayfun(@(L)plot(L),L);
view(-Pc.n);

fig_2d = cellFigure();
R = frameFromNormal(Pc.n);
L = arrayfun(@(L)Line(R*L.p0,R*L.d),L);
arrayfun(@(L)plot(L),L);