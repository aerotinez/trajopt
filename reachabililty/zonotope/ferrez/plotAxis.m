function plotAxis(n,p,color)
    arguments
        n (3,1) double;
        p (3,1) double = zeros(3,1);
        color (1,1) string = "#000000";
    end
    axe = gca;
    hold(axe,'on');
    quiver3(p(1),p(2),p(3),n(1),n(2),n(3), ...
        "LineWidth",2, ...
        "Color",color, ...
        "MaxHeadSize",1, ...
        "AutoScale","off");
    hold(axe,'off');
end