function x = interpolateStates(obj, t)
    arguments
        obj (1,1) trajopt.trajectory.trap
        t (:,1) double
    end
    T = obj.Time(:);
    X = obj.States;
    U = obj.Controls;
    P = obj.Parameters;

    F = obj.Plant(X',U',P')';
    idx = getInterval(obj,t);

    tau = t - T(idx);
    h = T(idx + 1) - T(idx);
    x0 = X(idx,:);
    f0 = F(idx,:);
    ff = F(idx + 1,:);
    x = x0 + tau.*f0 + (tau.^2./(2*h)).*(ff - f0);
end
