function x = interpolateStates(obj,t)
    arguments
        obj (1,1) trajopt.trajectory.lgps;
        t (:,1) double;
    end
    T = transposeTimeDomain(obj,obj.Time);
    L = trajopt.baryinterp(T,transposeTimeDomain(obj,t));
    x = L*obj.States;
end