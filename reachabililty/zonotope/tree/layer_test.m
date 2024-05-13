close("all"); clear; clc;

s = (1 + sqrt(5))/2;
G = [
    1,0,-s;
    1,0,s;
    0,-s,1;
    0,s,1;
    -s,1,0;
    s,1,0
    ].';

tic;
v = checkVertices(G);
toc;

tic;
zh = ZonoHull(G);
toc;

fig = figure();
axe = axes(fig);
for k = 1:size(G,2)
    zh.Layers(k).plot();
end
view(axe,3);
axis(axe,"equal");
box(axe,"on");

function v = checkVertices(G)
    f = @(g)[0.*g,g];
    g = cellfun(f,num2cell(G,1),"uniform",0);
    v = minkowskiSum(g{:});
end