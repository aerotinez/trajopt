classdef StraightSegment < RoadSegment 
    methods (Access = public)
        function obj = StraightSegment(arclength)
            obj@RoadSegment(arclength);
            obj.initData();
            obj.Heading = zeros(1,numel(obj.Parameter));
            obj.Curvature = zeros(1,numel(obj.Parameter)); 
        end
    end
    methods (Access = protected)
        function initData(obj)
            obj.Data = [
                obj.Parameter;
                zeros(2,numel(obj.Parameter))
                ];
        end
    end
end