function JoinSegment(obj,segment)
    arguments
        obj (1,1) Road;
        segment (1,1) RoadSegment;
    end
    obj.NumberOfSegments = obj.NumberOfSegments + 1;
    if isempty(obj.Data)
        initRoad(obj,segment);
        return
    end
    R = rotz(obj.Heading(end));
    t = obj.Data(:,end);
    segment.transform(rigidtform3d(R,t));
    s = segment.Parameter + obj.Parameter(end);
    obj.Parameter = [obj.Parameter,s];
    obj.Data = [obj.Data,segment.Data];
    obj.Curvature = [obj.Curvature,segment.Curvature];
    obj.Length = obj.Length + segment.Parameter(end);
    ang = wrapTo180(segment.Heading + obj.Heading(end));
    obj.Heading = [obj.Heading,ang];
end 