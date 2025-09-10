function u = interpolateControls(obj,t)
    arguments
        obj (1,1) trajopt.trajectory.lgps;
        t (:,1) double;
    end
    idx = ~isnan(sum(obj.Controls,2));
    T = transposeTimeDomain(obj,obj.Time(idx));
    L = trajopt.baryinterp(T,transposeTimeDomain(obj,t));
    u = L*obj.Controls(idx,:);
end