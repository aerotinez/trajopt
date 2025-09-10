function u = interpolateControls(obj,t)
    arguments
        obj (1,1) trajopt.trajectory.trap;
        t (:,1) double;
    end
    idx = getInterval(obj,t);
    T = t - obj.Time(idx);
    h = obj.Time(idx + 1) - obj.Time(idx);
    u0 = obj.Controls(idx,:);
    uf = obj.Controls(idx + 1,:);
    u = u0 + (T./h).*(uf - u0);
end