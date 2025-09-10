function initData(obj)
    arguments
        obj (1,1) ClothoidSegment;
    end
    s = obj.Parameter;
    [~,y] = ode45(@(t,y)clothoidRate(obj,t),s,zeros(3,1));
    obj.Data = y.';
end