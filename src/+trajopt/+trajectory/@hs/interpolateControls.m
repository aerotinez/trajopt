function u = interpolateControls(obj,t)
    arguments
        obj (1,1) trajopt.trajectory.hs
        t (:,1) double
    end
    N = numel(obj.Time);
    idxm = 2:2:N - 1;

    T = obj.Time(1:2:end);
    U = obj.Controls(1:2:end,:);
    Um = obj.Controls(idxm,:);
    idx = getInterval(obj,t);

    tau = t - T(idx);
    h = T(idx + 1) - T(idx);
    u0 = U(idx,:);
    um = Um(idx,:);
    uf = U(idx + 1,:);

    s = 2./(h.^2);
    A = s.*(tau - h./2).*(tau - h);
    B = -2*s.*tau.*(tau - h);
    C = s.*tau.*(tau - h./2);
    u = A.*u0 + B.*um + C.*uf;
end
