close("all"); clear; clc;

rng(10);
G = rand(3,3);
n = size(G,1);
m = size(G,2);

P = cellfun(@Plane,num2cell(G,1));
c = 'boypgcr';
SP = arrayfun(@(Pk)StereographicProjection(P(1),Pk),P(2:end));

fig_3d = sphereFigure();
arrayfun(@(P,c)plot(P,mcolor(c)),P,c(1:m));

fig_2d = cellFigure();
arrayfun(@(sp,c)plot(sp,mcolor(c)),SP,c(2:m));