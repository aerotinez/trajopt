classdef Road < handle
properties (GetAccess = public, SetAccess = protected)
    NumberOfSegments;
    Parameter = [];
    Data;
    Length;
    Heading;
    Curvature;
end
methods (Access = public)
function obj = Road()
    obj.Data = [];
    obj.Heading = 0;
    obj.NumberOfSegments = 0;
end
function Show(obj)
    scen = drivingScenario;
    lm = [laneMarking('Solid')
        laneMarking('Dashed','Length',2,'Space',4)
        laneMarking('Solid')];
    l = lanespec(2,'Marking',lm);
    road(scen,obj.Data.',7,'Lanes',l);
    plot(scen);
    axe = gca;
    axe.SortMethod = 'childorder';
    title(axe,'Road network');
end
function AddStraightSegment(obj,Length)
    S = StraightSegment(Length); 
    obj.JoinSegment(S);
end
function AddArcSegment(obj,Length,Radius,Direction)
    S = ArcSegment(Length,Radius,Direction);
    obj.JoinSegment(S);
end
function AddClothoidSegment(obj,Length,StartRadius,EndRadius,Direction) 
    S = ClothoidSegment(Length,StartRadius,EndRadius,Direction);
    obj.JoinSegment(S);            
end
end
methods (Access = protected) 
function JoinSegment(obj,Segment) 
    obj.NumberOfSegments = obj.NumberOfSegments + 1;
    if isempty(obj.Data)
        obj.Parameter = Segment.Parameter;
        obj.Data = Segment.Data;
        obj.Length = Segment.Parameter(end);
        obj.Heading = Segment.Heading;
        obj.Curvature = Segment.Curvature;
        return
    end
    Segment.Rotate(obj.Heading(end));
    Segment.Translate(obj.Data(:,end));
    obj.Parameter = [
        obj.Parameter.';
        Segment.Parameter(:,2:end).' + obj.Parameter(end).'
        ].';
    obj.Data = cat(2,obj.Data,Segment.Data(:,2:end));
    obj.Curvature = cat(2,obj.Curvature,Segment.Curvature(:,2:end));
    obj.Length = obj.Length + Segment.Parameter(end);
    ang = deg2rad(Segment.Heading(:,2:end));
    obj.Heading = cat(2,obj.Heading,rad2deg(wrapToPi(ang)));
end 
end
end