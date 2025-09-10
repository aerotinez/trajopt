function setHeading(obj)
    arguments
        obj (1,1) ArcSegment;
    end
    setHeading@CurveSegment(obj,arcLength(obj));
    obj.Heading = obj.Heading - 90;
end