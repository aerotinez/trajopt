close("all"); clear; clc;

G = [
    -0.5698,0.9575,-0.3414,-1.1797;
    -0.0020,0.7378,0.8886,1.3815
    ];

v = minkowskiVertices(G);
fig = myFigure();
plotGenerators(G./vecnorm(G,2,1))

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
    switch size(G,1)
        case 2
            f = @(g)quiver(0,0,g(1),g(2), ...
                "AutoScale","off", ...
                "MaxHeadSize",1, ...
                "LineWidth",2);
        case 3
            f = @(g)quiver3(0,0,0,g(1),g(2),g(3), ...
                "AutoScale","off", ...
                "MaxHeadSize",1, ...
                "LineWidth",2);
            view(axe,3);
    end
    hold(axe,"on");
    cellfun(f,num2cell(G,1));
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