classdef StraightSegment < RoadSegment 
    methods (Access = public)
        function obj = StraightSegment(arclength)
            obj@RoadSegment(arclength);
            initData(obj);
            obj.Heading = zeros(1,numel(obj.Parameter));
            obj.Curvature = zeros(1,numel(obj.Parameter)); 
        end
    end
    methods (Access = protected)
        initData(obj);
    end
end