classdef Road < handle
    properties (GetAccess = public, SetAccess = protected)
        NumberOfSegments = 0;
        Parameter;
        Data;
        Length;
        Heading;
        Curvature;
    end
    methods (Access = private)
        initRoad(obj);
        JoinSegment(obj);
    end
end