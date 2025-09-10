function initData(obj)
    arguments
        obj (1,1) StraightSegment;
    end
    obj.Data = [
        obj.Parameter;
        zeros(2,numel(obj.Parameter))
        ];
end