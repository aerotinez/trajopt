function setHeading(obj)
    arguments
        obj (1,1) ClothoidSegment;
    end
    setHeading@CurveSegment(obj,obj.Parameter);
end