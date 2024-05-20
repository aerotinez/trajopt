function plotFrame(R,p)
    arguments
        R (3,3) double;
        p (3,1) double = zeros(3,1);
    end
    plotAxis(R(:,1),p,"#FF0000");
    plotAxis(R(:,2),p,"#00FF00");
    plotAxis(R(:,3),p,"#0000FF");
end