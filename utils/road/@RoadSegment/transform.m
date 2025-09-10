function transform(obj,tform)
    arguments
        obj (1,1) RoadSegment;
        tform (1,1) rigidtform3d;
    end
    obj.Data = transformPointsForward(tform,obj.Data.').';
end