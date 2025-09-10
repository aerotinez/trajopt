function toNED(obj)
    arguments
        obj (1,1) ArcSegment;
    end
    tform = rigidtform3d(rotz(90),zeros(3,1));
    obj.Data = transformPointsInverse(tform,obj.Data.').';
end 