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
        function setDirection(obj,dir)
            if dir == "right"
                tform = affinetform3d([1,-1,1,1].*eye(4));
                obj.Data = transformPointsForward(tform,obj.Data.').';
                obj.Heading = -obj.Heading;
                obj.Curvature = -obj.Curvature;
            end
        end
        function transform(obj,tform)
            arguments
                obj (1,1) RoadSegment;
                tform (1,1) rigidtform3d;
            end
            obj.Data = transformPointsForward(tform,obj.Data.').';
        end
        function plot(obj)
            plot(obj.Data(1,:),obj.Data(2,:));
            view([90,-90]);
            set(gca,'Ydir','reverse');
            title('Road segment');
            xlabel('x(m)');
            ylabel('y(m)');
            axis('equal'); 
        end 
    end
    methods (Access = protected, Abstract)
        initData(obj);
    end 
end