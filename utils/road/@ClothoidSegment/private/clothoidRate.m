function dC = clothoidRate(obj,t)
    arguments
        obj (1,1) ClothoidSegment;
        t 
    end
    k0 = 1/obj.StartRadius;
    kf = 1/obj.EndRadius;
    L = obj.Length;
    theta = [k0,(kf - k0)/(2*L)]*[t;t.^2];
    dC = [cos(theta);sin(theta);0.*theta];
end