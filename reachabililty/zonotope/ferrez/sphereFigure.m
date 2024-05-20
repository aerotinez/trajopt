function fig = sphereFigure()
    fig = figure();
    axe = axes(fig);
    view(axe,3);
    box(axe,"on");
    axis(axe,"equal");
    camproj(axe,"perspective");
    xlabel(axe,"x (m)");
    ylabel(axe,"y (m)");
    zlabel(axe,"z (m)");
end