function setHeading(obj,s)
    arguments
        obj (1,1) CurveSegment;
        s (1,:) double;
    end
    fz = @(x)x(1);
    f = @(s)rad2deg(fz(rotm2eul(obj.fRotationMatrix(s))));
    obj.Heading = arrayfun(f,s);
end