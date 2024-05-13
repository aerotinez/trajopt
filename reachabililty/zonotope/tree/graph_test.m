close("all"); clear; clc;

G = [
    1,sqrt(3),0;
    1,-sqrt(3),0;
    2,0,0;
    0,0,2
    ].';

e0 = zeros(size(G,1),1);

v = checkVertices(G);
v = 2.*(v - sum(v,2)./size(v,2));

fig = figure();
axe = axes(fig);
hold(axe,"on");
scatter3(axe,v(1,:),v(2,:),v(3,:),"filled");
view(axe,3)
plot(zonotope(e0,G),1:3);
hold(axe,"off");
box(axe,"on");
axis(axe,"equal");

function v = checkVertices(G)
    f = @(g)[0.*g,g];
    g = cellfun(f,num2cell(G,1),"uniform",0);
    v = minkowskiSum(g{:});
end