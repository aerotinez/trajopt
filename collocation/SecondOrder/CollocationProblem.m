classdef CollocationProblem < handle
    properties (GetAccess = public, SetAccess = private)
        Problem;
        Mesh;
        NumNodes;
    end
    methods (Access = public)
        function obj = CollocationProblem(ns)
            % CollocationProblem
            %   ns: number of segments
            %       (1,1) double {mustBeInteger, mustBePositive} 
            arguments
                ns (1,1) double {mustBeInteger, mustBePositive}
            end
            obj.Problem = casadi.Opti();
            obj.NumNodes = ns + 1;
            obj.Mesh = linspace(0, 1, obj.NumNodes);
        end
    end
end
