classdef RoadSegment < handle
    properties (GetAccess = public, SetAccess = protected)
        Parameter;
        Data;
        Length;
        Heading;
        Curvature;
    end
    methods (Access = public)
        function obj = RoadSegment(arclength)
            arguments
                arclength (1,1) double;
            end
            obj.Length = arclength;
            obj.Parameter = linspace(0,arclength,arclength + 1);
        end
    end
    methods (Access = protected, Abstract)
        initData(obj);
    end 
end