function setCurvature(obj)
    arguments
        obj (1,1) ClothoidSegment;
    end
    setCurvature@CurveSegment(obj,obj.Parameter);
end