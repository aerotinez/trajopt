function addArc(obj,Length,Radius,Direction)
    arguments
        obj (1,1) Road;
        Length (1,1) double {mustBePositive};
        Radius (1,1) double;
        Direction 
    end
    S = ArcSegment(Length,Radius,Direction);
    JoinSegment(obj,S);
end