function setCurvature(obj,s)
    arguments
        obj (1,1) CurveSegment;
        s (1,:) double;
    end
    obj.Curvature = arrayfun(obj.fCurvature,s);
end