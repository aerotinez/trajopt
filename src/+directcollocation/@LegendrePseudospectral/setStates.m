function setStates(obj,states)
    arguments
        obj (1,1) directcollocation.LegendrePseudospectral;
        states table;
    end
    setStates@directcollocation.Program(obj,states);
end