classdef trap < trajopt.trajectory.Trajectory
    methods (Access = protected)
        x = interpolateStates(obj,t);
        u = interpolateControls(obj,t);
    end
end