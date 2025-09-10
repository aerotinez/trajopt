function addClothoid(obj,Length,StartRadius,EndRadius,Direction) 
    arguments
        obj (1,1) Road;
        Length (1,1) double {mustBePositive};
        StartRadius (1,1) double;
        EndRadius (1,1) double;
        Direction 
    end
    S = ClothoidSegment(Length,StartRadius,EndRadius,Direction);
    JoinSegment(obj,S);            
end