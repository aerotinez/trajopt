function setStates(obj,states)
    arguments
        obj (1,1) directcollocation.LegendreGaussRadau;
        states table;
    end
    setStates@directcollocation.LegendrePseudospectral(obj,states);
end