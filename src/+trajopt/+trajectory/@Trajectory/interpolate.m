function [t,x,u] = interpolate(obj,ns)
    arguments
        obj (1,1) trajopt.trajectory.Trajectory;
        ns (1,1) double {mustBeReal,mustBeInteger,mustBePositive} = 1E03;
    end
    t = linspace(obj.Time(1),obj.Time(end),ns)';
    x = interpolateStates(obj,t);
    u = interpolateControls(obj,t);
end