function T = transposeTimeDomain(obj,t)
    arguments
        obj (1,1) trajopt.trajectory.lgps;
        t (:,1) double;
    end
    t0 = obj.Time(1);
    tf = obj.Time(end);
    T = (t0 - 2*t + tf)./(t0 - tf);
end