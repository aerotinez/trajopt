function setCurvature(obj)
    arguments
        obj (1,1) ArcSegment;
    end
    setCurvature@CurveSegment(obj,arcLength(obj));
end