function fig = cellFigure()
    fig = figure();
    axe = axes(fig);
    box(axe,'on');
    axis(axe,'equal');
    xlabel(axe,'x (m)');
    ylabel(axe,'y (m)');
end