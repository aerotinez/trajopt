function setFormula(obj)
    arguments
        obj (1,1) ClothoidSegment;
    end
    obj.Formula = @(t)int(clothoidRate(obj,t),t);
end