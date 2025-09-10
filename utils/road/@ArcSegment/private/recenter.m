function recenter(obj)
    arguments
        obj (1,1) ArcSegment;
    end
    tform = rigidtform3d(eye(3),[obj.Radius,0,0]');
    obj.Data = transformPointsInverse(tform,obj.Data.').';
end