function addStraight(obj,Length)
    arguments
        obj (1,1) Road;
        Length (1,1) double {mustBePositive};
    end
    S = StraightSegment(Length); 
    JoinSegment(obj,S);
end