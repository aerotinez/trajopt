function initRoad(obj,segment)
    arguments
        obj (1,1) Road;
        segment (1,1) RoadSegment;
    end
    obj.Parameter = segment.Parameter;
    obj.Data = segment.Data;
    obj.Length = segment.Parameter(end);
    obj.Heading = segment.Heading;
    obj.Curvature = segment.Curvature;
end