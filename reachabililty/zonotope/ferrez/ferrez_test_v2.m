close("all"); clear; clc;

rng(16);
G = rand(3,4);
n = size(G,1);
m = size(G,2);

P = cellfun(@Plane,num2cell(G,1));
Pc = Plane(G(:,end)).translate([0;0;0.5]);
c = 'boypgcr';
% SP = arrayfun(@(Pk)StereographicProjection(P(end),Pk),P(1:end - 1));

fig_3d = sphereFigure();
% arrayfun(@(P,c)plot(P,mcolor(c),1),P,c(1:m));
% plot(Pc,"#ffffff",1);
arrayfun(@(P)plot(intersect(Pc,P)),P(1:end - 1));
view(Pc.n);

% fig_2d = cellFigure();
% arrayfun(@(sp,c)plot(sp,mcolor(c)),SP,c(1:m - 1));
% 
% fig = cellFigure();
% arrayfun(@(sp,c)plot(toLine(sp),mcolor(c)),SP,c(1:m - 1));