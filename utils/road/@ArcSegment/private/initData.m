function initData(obj)
    arguments
        obj (1,1) ArcSegment;
    end
    obj.Data = obj.Formula(arcLength(obj));
end