close("all"); clear; clc;

rng(10);
G = rand(3,3);
n = size(G,1);
m = size(G,2);

P = cellfun(@Plane,num2cell(G,1));
c = 'boypgcr';

fig_3d = sphereFigure();
arrayfun(@(P,c)plot(P,mcolor(c)),P,c(1:m));