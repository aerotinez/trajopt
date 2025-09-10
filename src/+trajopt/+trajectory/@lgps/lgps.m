classdef lgps < trajopt.trajectory.Trajectory
    methods (Access = protected)
        T = transposeTimeDomain(obj,t);
        x = interpolateStates(obj,t);
        u = interpolateControls(obj,t);
    end
end