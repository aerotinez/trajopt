classdef SecondOrderCollocation < handle
    properties (GetAccess = public, SetAccess = protected)
        Objective;
        Kinematics;
        KinematicRates;
        Dynamics;
        Mesh;
        Time;
        Coordinates;
        Speeds;
        Controls;
        Parameters;
        InitialTime;
        FinalTime;
        InitialCoordinates;
        FinalCoordinates;
        InitialSpeeds;
        FinalSpeeds;
    end
    properties (Access = private)
        CoordinateNames;
        SpeedNames;
        ControlNames;
        CoordinateUnits;
        SpeedUnits;
        ControlUnits;
    end
    properties (Access = protected)
        NumCoordinates;
        NumSpeeds;
        NumControls;
        NumParameters;
        NumNodes;
    end
    properties (Access = protected)
        Problem;
        Q; % (n x ns) coordinates <casadi.MX>
        U; % (m x ns) speeds <casadi.MX>
        F; % (m x ns) controls <casadi.MX>
        T0; % (1,1) initial time <casadi.MX>
        Tf; % (1,1) final time <casadi.MX>
        NumInterpSamples = 100; % (1,1) number of interpolation samples <double>
    end
    methods (Access = public)
        function obj = SecondOrderCollocation(J,W,Wd,f,ns)
            % Second-order direct collocation
            % 
            % Dimensions:
            %   n: number of coordinates
            %   m: number of independent speeds
            %   ns: number of segments
            %
            % Function arguments:
            %
            %   J: (1,1) objective function 
            %      <ObjectiveFunction> (1,1)
            %
            %   W: (n x m) kinematic jacobian 
            %      <casadi.Function> (1,1)
            %
            %   Wd: (n x m) kinematic jacobian time derivative 
            %       <casadi.Function> (1,1)
            %
            %   f: (m x 1) dynamics (x_dot = f(x,u,p,t)) 
            %      <casadi.Function> (1,1)
            %
            %   ns: (1,1) number of segments 
            %       <double> (1,1)
            %
            arguments
                J (1,1) ObjectiveFunction;
                W (1,1) casadi.Function;
                Wd (1,1) casadi.Function;
                f (1,1) casadi.Function;
                ns (1,1) double {mustBeInteger,mustBePositive}
            end
            obj.Objective = J;
            obj.Kinematics = W;
            obj.KinematicRates = Wd;
            obj.Dynamics = f;
            obj.Mesh = linspace(0,1,ns + 1);
            obj.Problem = casadi.Opti();
            obj.setDimensions();
            obj.initializeNLPVariables();
            obj.T0 = obj.Problem.variable(1);
            obj.Tf = obj.Problem.variable(1);
        end
    end
    methods (Access = private)
        function setDimensions(obj)
            c = obj.Dynamics.sx_in;
            obj.NumCoordinates = size(c{1},1);
            obj.NumSpeeds = size(c{2},1);
            obj.NumControls = size(c{3},1);
            obj.NumParameters = size(c{4},1);
            obj.NumNodes = numel(obj.Mesh);
        end
        function validateCoordinates(obj,q)
            if size(q,1) ~= obj.NumCoordinates
                msg = "q must have as many rows as there are coordinates";
                error(msg);
            end
        end
        function validateSpeeds(obj,u)
            if size(u,1) ~= obj.NumSpeeds
                msg = "u must have as many rows as there are speeds";
                error(msg);
            end
        end
        function validateControls(obj,v)
            if size(v,1) ~= obj.NumControls
                msg = "v must have as many rows as there are controls";
                error(msg);
            end
        end
        function validateParameters(obj,p)
            if size(p,1) ~= obj.NumParameters
                msg = "p must have as many rows as there are parameters";
                error(msg);
            end
        end
        function validateNodes(obj,x)
            if size(x,2) ~= obj.NumNodes
                msg = "x must have as many columns as there are nodes";
                error(msg);
            end
        end
        function initializeNLPCoordinatesVariables(obj)
            f = @(i)obj.Problem.variable(obj.NumCoordinates);
            obj.Q = cellfun(f,num2cell(1:obj.NumNodes),"UniformOutput",false);
        end
        function initializeNLPSpeedVariables(obj)
            f = @(i)obj.Problem.variable(obj.NumSpeeds);
            obj.U = cellfun(f,num2cell(1:obj.NumNodes),"UniformOutput",false);
        end
        function initializeNLPControlVariables(obj)
            f = @(i)obj.Problem.variable(obj.NumControls);
            obj.F = cellfun(f,num2cell(1:obj.NumNodes),"UniformOutput",false);
        end
        function initializeNLPVariables(obj)
            obj.initializeNLPCoordinatesVariables();
            obj.initializeNLPSpeedVariables();
            obj.initializeNLPControlVariables();
        end
    end
end