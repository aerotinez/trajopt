classdef Road < handle
    properties (GetAccess = public, SetAccess = protected)
        NumberOfSegments;
        Parameter;
        Data;
        Length;
        Heading;
        Curvature;
    end
    methods (Access = public)
        function plot(obj)
            scen = drivingScenario;
            lm = [laneMarking('Solid')
                laneMarking('Dashed','Length',2,'Space',4)
                laneMarking('Solid')];
            l = lanespec(2,'Marking',lm,"width",3.5);
            road(scen,obj.Data.',0.*obj.Data(1,:).',"Lanes",l);
            plot(scen);
            axe = gca;
            axe.SortMethod = 'childorder';
            title(axe,'Road network');
        end
        function addStraight(obj,Length)
            S = StraightSegment(Length); 
            obj.JoinSegment(S);
        end
        function addArc(obj,Length,Radius,Direction)
            S = ArcSegment(Length,Radius,Direction);
            obj.JoinSegment(S);
        end
        function addClothoid(obj,Length,StartRadius,EndRadius,Direction) 
            S = ClothoidSegment(Length,StartRadius,EndRadius,Direction);
            obj.JoinSegment(S);            
        end
    end
    methods (Access = private)
        function initRoad(obj,segment)
            obj.Parameter = segment.Parameter;
            obj.Data = segment.Data;
            obj.Length = segment.Parameter(end);
            obj.Heading = segment.Heading;
            obj.Curvature = segment.Curvature;
        end
        function JoinSegment(obj,segment) 
            obj.NumberOfSegments = obj.NumberOfSegments + 1;
            if isempty(obj.Data)
                obj.initRoad(segment);
                return
            end
            R = rotz(obj.Heading(end));
            t = obj.Data(:,end);
            segment.transform(rigidtform3d(R,t));
            s = segment.Parameter(:,2:end) + obj.Parameter(end);
            obj.Parameter = [obj.Parameter,s];
            obj.Data = [obj.Data,segment.Data(:,2:end)];
            obj.Curvature = [obj.Curvature,segment.Curvature(:,2:end)];
            obj.Length = obj.Length + segment.Parameter(end);
            ang = wrapTo180(segment.Heading(:,2:end) + obj.Heading(end));
            obj.Heading = [obj.Heading,ang];
        end 
    end
end