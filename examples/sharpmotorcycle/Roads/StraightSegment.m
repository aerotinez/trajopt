classdef StraightSegment < RoadSegment 
methods (Access = public)
function obj = StraightSegment(Length)
    obj.Parameter = linspace(0,Length,Length + 1);
    obj.Data = [
        obj.Parameter;
        zeros(2,numel(obj.Parameter))
        ];
    obj.Length = Length;
    obj.Heading = zeros(1,numel(obj.Parameter));
    obj.Curvature = zeros(1,numel(obj.Parameter));
end 
end
end