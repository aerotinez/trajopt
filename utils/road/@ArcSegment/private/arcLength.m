function s = arcLength(obj)
    arguments
        obj (1,1) ArcSegment;
    end
    s = linspace(0,obj.Angle,obj.Length + 1);
end