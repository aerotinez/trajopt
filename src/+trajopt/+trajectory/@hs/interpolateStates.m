function x = interpolateStates(obj,t)
    arguments
        obj (1,1) trajopt.trajectory.hs
        t (:,1) double
    end

    T = obj.Time(1:2:end);
    X = obj.States(1:2:end,:);
    U = obj.Controls(1:2:end,:);
    P = obj.Parameters(1:2:end,:);

    Xm = obj.States(2:2:end - 1,:);
    Um = obj.Controls(2:2:end - 1,:);
    Pm = obj.Parameters(2:2:end - 1,:);

    F = obj.Plant(X',U',P')';
    Fm = obj.Plant(Xm',Um',Pm')';

    idx = getInterval(obj,t);

    tau = t - T(idx);
    h = T(idx + 1) - T(idx);
    x0 = X(idx,:);
    f0 = F(idx,:);
    fm = Fm(idx,:);
    ff = F(idx + 1,:);

    s = tau./h;
    A = (-3*f0 + 4*fm - ff)/2;
    B = (2*f0 - 4*fm + 2*ff)/3;
    x = x0 + h.*(f0.*s + A.*s.^2 + B.*s.^3);
end
