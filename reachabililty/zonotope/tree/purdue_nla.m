clear; clc;

n = 2;
m = 4;

c = zeros(n,1);

G = [
    -0.5698,0.9575,-0.3414,-1.1797;
    -0.0020,0.7378,0.8886,1.3815
    ];

v = minkowskiVertices(G);
P = cellfun(@(g)pnplane(c,g),num2cell(G,1));
hp = cell2mat(arrayfun(@(P)P.r0.'./norm(P.r0),P,"uniform",0));

fig = myFigure();
% plotGenerators(G./vecnorm(G,2,1))
plotGenerators(hp)

function P = pnplane(c,g)
    arguments
        c (:,1) double;
        g (:,1) double;
    end
    n = g./norm(g);
    r = -ones(size(n,1) - 1,1);
    d = dot(n,c);
    z = (d - dot(n(1:end - 1),r))./n(end);
    r0 = [r;z];
    P = struct('n',n.','r0',r0.');
end

function fig = myFigure()
    fig = figure();
    axe = axes(fig);
    axis(axe,"equal");
    box(axe,"on");
    xlabel(axe,"x (m)");
    ylabel(axe,"y (m)");
    zlabel(axe,"z (m)");
end

function plotGenerators(G)
    axe = gca;
    ca = 'boypgcr';
    c = cellstr(arrayfun(@mcolor,ca(1:size(G,2))));
    switch size(G,1)
        case 2
            f = @(g,c)quiver(0,0,g(1),g(2), ...
                "Color",c, ...
                "AutoScale","off", ...
                "MaxHeadSize",1, ...
                "LineWidth",2);
        case 3
            f = @(g,c)quiver3(0,0,0,g(1),g(2),g(3), ...
                "Color",c, ...
                "AutoScale","off", ...
                "MaxHeadSize",1, ...
                "LineWidth",2);
            view(axe,3);
    end
    hold(axe,"on");
    cellfun(f,num2cell(G,1),c);
    hold(axe,"off");
end

function plotVertices(v)
    axe = gca;
    hold(axe,"on");
    switch size(v,1)
        case 2
            scatter(axe,v(1,:),v(2,:),"filled");
        case 3
            scatter3(axe,v(1,:),v(2,:),v(3,:),"filled");
            view(axe,3);
            camproj(axe,"perspective");
    end
    hold(axe,"off");
end