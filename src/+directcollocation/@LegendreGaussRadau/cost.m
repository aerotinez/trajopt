function cost(obj)
    arguments
        obj (1,1) directcollocation.LegendreGaussRadau;
    end
    cost@directcollocation.LegendrePseudospectral(obj);
end