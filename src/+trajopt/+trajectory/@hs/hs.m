classdef hs < trajopt.trajectory.Trajectory
    methods (Access = protected)
        idx = getInterval(obj,t);
        x = interpolateStates(obj,t);
        u = interpolateControls(obj,t);
    end
end