function setMesh(obj)
    arguments
        obj (1,1) directcollocation.LegendreGauss
    end

    n = obj.NumNodes;

    if n == 1
        obj.Mesh = 0.5;                         % single Gauss node
    else
        x_m11 = directcollocation.golubwelsch(n, 0, 0);  % (-1,1)
        obj.Mesh = (0.5*(x_m11 + 1)).';                  % row in (0,1)
    end

    obj.NumIntervals = numel(obj.Mesh) - 1;
end
