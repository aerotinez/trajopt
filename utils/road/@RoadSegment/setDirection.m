function setDirection(obj,dir)
    arguments
        obj (1,1) RoadSegment;
        dir (1,1) string {mustBeMember(dir,["left","right"])};
    end
    if dir == "right"
        tform = affinetform3d([1,-1,1,1].*eye(4));
        obj.Data = transformPointsForward(tform,obj.Data.').';
        obj.Heading = -obj.Heading;
        obj.Curvature = -obj.Curvature;
    end
end