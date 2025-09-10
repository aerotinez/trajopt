function idx = getInterval(obj,t)
    arguments
        obj (1,1) trajopt.trajectory.hs;
        t (:,1) double {mustBeReal,mustBeFinite};
    end
    mustBeInRange(t,obj.Time(1),obj.Time(end));

    T = obj.Time(1:2:end);
    N = numel(T) - 1;

    idx = zeros(size(t));

    for n = 1:numel(t)
        if t(n) == T(1)
            idx(n) = 1;
        elseif t(n) == T(end)
            idx(n) = N;
        else
            idx(n) = find(T <= t(n), 1,'last');
        end
    end
end
