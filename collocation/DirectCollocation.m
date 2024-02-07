classdef DirectCollocation < handle
    properties (GetAccess = public, SetAccess = protected)
        Objective;
        Plant;
        Mesh;
        Time;
        State;
        Control;
        Parameters;
        InitialTime;
        FinalTime;
        InitialState;
        FinalState;
    end
    properties (Access = private)
        StateName;
        ControlName;
        StateUnit;
        ControlUnit;
        TimeUnit;
    end
    properties (Access = protected)
        NumStates;
        NumControls;
        NumParameters;
        NumNodes;
    end
    properties (Access = protected)
        Problem;
        X;
        U;
        T0;
        Tf;
        ns = 100;
    end
    methods
        function obj = DirectCollocation(objective,plant,mesh)
            arguments
                objective (1,1) ObjectiveFunction;
                plant (1,1) casadi.Function;
                mesh (1,:) double;
            end
            obj.Objective = objective;
            obj.Plant = plant;
            obj.Mesh = mesh;
            obj.setDimensions();
            obj.Problem = casadi.Opti();
            obj.initializeNLPStateVariables();
            obj.initializeNLPControlVariables();
            obj.T0 = obj.Problem.variable(1);
            obj.Tf = obj.Problem.variable(1);
        end
        function setState(obj,x)
            arguments
                obj (1,1) DirectCollocation;
                x double;
            end
            obj.validateState(x(:,1));
            if isequal(size(x),[obj.NumStates,1])
                obj.State = repmat(x,1,obj.NumNodes);
            else
                obj.validateNodes(x);
                obj.State = x;
            end 
            for i = 1:obj.NumNodes
                obj.Problem.set_initial(obj.X{i},obj.State(:,i));
            end
        end
        function setControl(obj,u)
            arguments
                obj (1,1) DirectCollocation;
                u double;
            end
            obj.validateControl(u(:,1));
            if isequal(size(u),[obj.NumControls,1])
                obj.Control = repmat(u,1,obj.NumNodes);
            else
                obj.validateNodes(u);
                obj.Control = u;
            end 
            for i = 1:obj.NumNodes
                obj.Problem.set_initial(obj.U{i},obj.Control(:,i));
            end
        end
        function setParameters(obj,p)
            arguments
                obj (1,1) DirectCollocation;
                p double;
            end
            if isequal(size(p),[obj.NumParameters,1])
                obj.Parameters = repmat(p,1,obj.NumNodes);
                return;
            end
            obj.validateNodes(p);
            obj.Parameters = p;
        end
        function setInitialState(obj,x0)
            arguments
                obj (1,1) DirectCollocation;
                x0 (:,1) double;
            end
            obj.validateState(x0);
            obj.InitialState = x0;
            obj.Problem.subject_to(obj.X{1} == x0);
        end
        function setFinalState(obj,xf)
            arguments
                obj (1,1) DirectCollocation;
                xf (:,1) double;
            end
            obj.validateState(xf);
            obj.FinalState = xf;
            obj.Problem.subject_to(obj.X{end} == xf);
        end
        function setInitialTime(obj,t0)
            arguments
                obj (1,1) DirectCollocation;
                t0 (1,1) double;
            end
            obj.T0.delete();
            obj.InitialTime = t0;
        end
        function setFinalTime(obj,tf)
            arguments
                obj (1,1) DirectCollocation;
                tf (1,1) double;
            end
            obj.Tf.delete();
            obj.FinalTime = tf;
        end
        function setStateLowerBound(obj,lb)
            arguments
                obj (1,1) DirectCollocation;
                lb (:,1) double;
            end
            obj.validateState(lb);
            for i = 1:obj.NumNodes
                obj.Problem.subject_to(obj.X{i} >= lb);
            end
        end
        function setStateUpperBound(obj,ub)
            arguments
                obj (1,1) DirectCollocation;
                ub (:,1) double;
            end
            obj.validateState(ub);
            for i = 1:obj.NumNodes
                obj.Problem.subject_to(obj.X{i} <= ub);
            end
        end
        function setStateBounds(obj,lb,ub)
            arguments
                obj (1,1) DirectCollocation;
                lb (:,1) double;
                ub (:,1) double;
            end
            obj.setStateLowerBound(lb);
            obj.setStateUpperBound(ub); 
        end
        function setControlLowerBound(obj,lb)
            arguments
                obj (1,1) DirectCollocation;
                lb (:,1) double;
            end
            obj.validateControl(lb);
            for i = 1:obj.NumNodes
                obj.Problem.subject_to(obj.U{i} >= lb);
            end
        end
        function setControlUpperBound(obj,ub)
            arguments
                obj (1,1) DirectCollocation;
                ub (:,1) double;
            end
            obj.validateControl(ub);
            for i = 1:obj.NumNodes
                obj.Problem.subject_to(obj.U{i} <= ub);
            end
        end 
        function setControlBounds(obj,lb,ub)
            arguments
                obj (1,1) DirectCollocation;
                lb (:,1) double;
                ub (:,1) double;
            end
            obj.setControlLowerBound(lb);
            obj.setControlUpperBound(ub);
        end
        function setInitialTimeGuess(obj,t0)
            arguments
                obj (1,1) DirectCollocation;
                t0 (1,1) double;
            end
            obj.Problem.set_initial(obj.T0,t0);
        end
        function setFinalTimeGuess(obj,tf)
            arguments
                obj (1,1) DirectCollocation;
                tf (1,1) double;
            end
            obj.Problem.set_initial(obj.Tf,tf);
        end
        function setInitialTimeLowerBound(obj,lb)
            arguments
                obj (1,1) DirectCollocation;
                lb (1,1) double;
            end
            obj.Problem.subject_to(obj.T0 >= lb);
        end
        function setInitialTimeUpperBound(obj,ub)
            arguments
                obj (1,1) DirectCollocation;
                ub (1,1) double;
            end
            obj.Problem.subject_to(obj.T0 <= ub);
        end
        function setInitialTimeBounds(obj,lb,ub)
            arguments
                obj (1,1) DirectCollocation;
                lb (1,1) double;
                ub (1,1) double;
            end
            obj.setInitialTimeLowerBound(lb);
            obj.setInitialTimeUpperBound(ub);
        end
        function setFinalTimeLowerBound(obj,lb)
            arguments
                obj (1,1) DirectCollocation;
                lb (1,1) double;
            end
            obj.Problem.subject_to(obj.Tf >= lb);
        end
        function setFinalTimeUpperBound(obj,ub)
            arguments
                obj (1,1) DirectCollocation;
                ub (1,1) double;
            end
            obj.Problem.subject_to(obj.Tf <= ub);
        end
        function setFinalTimeBounds(obj,lb,ub)
            arguments
                obj (1,1) DirectCollocation;
                lb (1,1) double;
                ub (1,1) double;
            end
            obj.setFinalTimeLowerBound(lb);
            obj.setFinalTimeUpperBound(ub);
        end
        function setInterpolationSampleRate(obj,ns)
            arguments
                obj (1,1) DirectCollocation;
                ns (1,1) double;
            end
            obj.ns = ns;
        end
        function J = cost(obj)
            [t0,tf] = obj.getTimes();
            J = 0;
            if ~isempty(obj.Objective.Lagrange)
                L = cell(1,obj.NumNodes);
                for i = 1:obj.NumNodes
                    L{i} = obj.Objective.Lagrange(obj.X{i},obj.U{i});
                end
                q = (tf - t0).*[L{:}].';
                dT = diff(obj.Mesh);
                b = (1/2).*sum([dT,0;0,dT],1);
                J = J + b*q;
            end
            if ~isempty(obj.Objective.Mayer)
                M = obj.Objective.Mayer(t0,obj.X{1},tf,x{end});
                J = J + M; 
            end
        end
        function varargout = solve(obj,solver)
            arguments
                obj (1,1) DirectCollocation;
                solver (1,1) string = "ipopt";
            end
            obj.collocationConstraints();
            J = obj.cost();
            obj.Problem.minimize(J);
            obj.Problem.solver(char(solver));
            sol = obj.Problem.solve();
            obj.setState(sol.value([obj.X{:}]));
            obj.setControl(sol.value([obj.U{:}]));
            if isempty(obj.InitialTime)
                obj.setInitialTime(sol.value(obj.T0));
            end
            if isempty(obj.FinalTime)
                obj.setFinalTime(sol.value(obj.Tf));
            end
            obj.setTime();
            if nargout > 0
                varargout{1} = sol;
            end
        end
        function [t,x,u] = interpolate(obj)
            t = obj.interpolateTime();
            x = zeros(obj.NumStates,numel(t));
            u = zeros(obj.NumControls,numel(t));
            for i = 1:obj.NumNodes - 1
                x(:,(i - 1)*obj.ns + 1:i*obj.ns) = obj.interpolateState(i);
                u(:,(i - 1)*obj.ns + 1:i*obj.ns) = obj.interpolateControl(i);
            end
        end
        function setStateName(obj,state_name)
            arguments
                obj (1,1) DirectCollocation;
                state_name (:,1) string;
            end
            obj.validateState(state_name);
            obj.StateName = state_name;
        end
        function setControlName(obj,control_name)
            arguments
                obj (1,1) DirectCollocation;
                control_name (:,1) string;
            end
            obj.validateControl(control_name);
            obj.ControlName = control_name;
        end
        function setStateUnit(obj,state_unit)
            arguments
                obj (1,1) DirectCollocation;
                state_unit (:,1) string;
            end
            obj.validateState(state_unit);
            obj.StateUnit = state_unit;
        end
        function setControlUnit(obj,control_unit)
            arguments
                obj (1,1) DirectCollocation;
                control_unit (:,1) string;
            end
            obj.validateControl(control_unit);
            obj.ControlUnit = control_unit;
        end
        function fig = plotStateNodes(obj,rows,cols)
            fig = figure();
            tiledlayout(rows,cols,"Parent",fig);
            for i = 1:obj.NumStates
                nexttile();
                scatter(obj.Time,obj.State(i,:),20,'k',"filled");
                box(gca,"on");
                xlim([obj.InitialTime,obj.FinalTime]);
                title(obj.StateName(i));
                xlabel(obj.TimeUnit);
                ylabel(obj.StateUnit(i));
            end
        end
        function fig = plotControlNodes(obj,rows,cols)
            fig = figure();
            tiledlayout(rows,cols,"Parent",fig);
            for i = 1:obj.NumControls
                nexttile();
                scatter(obj.Time,obj.Control(i,:),20,'k',"filled");
                box(gca,"on");
                xlim([obj.InitialTime,obj.FinalTime]);
                title(obj.ControlName(i));
                xlabel(obj.TimeUnit);
                ylabel(obj.ControlUnit(i));
            end
        end
        function fig = plotStateInterpolation(obj,row,col)
            [t,x,~] = obj.interpolate();
            fig = figure();
            tiledlayout(row,col,"Parent",fig);
            for i = 1:obj.NumStates
                nexttile();
                plot(t,x(i,:),'k');
                box(gca,"on");
                xlim([obj.InitialTime,obj.FinalTime]);
                title(obj.StateName(i));
                xlabel(obj.TimeUnit);
                ylabel(obj.StateUnit(i));
            end
        end
        function fig = plotControlInterpolation(obj,row,col)
            [t,~,u] = obj.interpolate();
            fig = figure();
            tiledlayout(row,col,"Parent",fig);
            for i = 1:obj.NumControls
                nexttile();
                plot(t,u(i,:),'k');
                box(gca,"on");
                xlim([obj.InitialTime,obj.FinalTime]);
                title(obj.ControlName(i));
                xlabel(obj.TimeUnit);
                ylabel(obj.ControlUnit(i));
            end
        end
        function fig = plotState(obj,row,col)
            fig = figure();
            tiledlayout(row,col,"Parent",fig);
            [t,x,~] = obj.interpolate();
            for i = 1:obj.NumStates
                nexttile();
                hold(gca,"on");
                plot(t,x(i,:),'k');
                scatter(obj.Time,obj.State(i,:),20,'k',"filled");
                hold(gca,"off");
                box(gca,"on");
                xlim([obj.InitialTime,obj.FinalTime]);
                title(obj.StateName(i));
                xlabel(obj.TimeUnit);
                ylabel(obj.StateUnit(i));
            end
        end
        function fig = plotControl(obj,row,col)
            fig = figure();
            tiledlayout(row,col,"Parent",fig);
            [t,~,u] = obj.interpolate();
            for i = 1:obj.NumControls
                nexttile();
                hold(gca,"on");
                plot(t,u(i,:),'k');
                scatter(obj.Time,obj.Control(i,:),20,'k',"filled");
                hold(gca,"off");
                box(gca,"on");
                xlim([obj.InitialTime,obj.FinalTime]);
                title(obj.ControlName(i));
                xlabel(obj.TimeUnit);
                ylabel(obj.ControlUnit(i));
            end
        end
    end
    methods (Access = protected)
        function setDimensions(obj)
            c = obj.Plant.sx_in;
            obj.NumStates = size(c{1},1);
            obj.NumControls = size(c{2},1);
            obj.NumParameters = size(c{3},1);
            obj.NumNodes = numel(obj.Mesh);
        end
        function validateState(obj,x)
            if size(x,1) ~= obj.NumStates
                msg = "X must have as many elements as there are states."; 
                error(msg);
            end
        end
        function validateControl(obj,u)
            if size(u,1) ~= obj.NumControls
                msg = "U must have as many elements as there are controls."; 
                error(msg);
            end
        end
        function validateParameters(obj,p)
            if size(p,1) ~= obj.NumParameters
                msg = "P must have as many elements as there are parameters."; 
                error(msg);
            end
        end
        function validateNodes(obj,x)
            if size(x,2) ~= obj.NumNodes
                msg = "X must have as many columns as there are nodes."; 
                error(msg);
            end
        end
        function initializeNLPStateVariables(obj)
            obj.X = cell(1,obj.NumNodes);
            for i = 1:obj.NumNodes
                obj.X{i} = obj.Problem.variable(obj.NumStates);
            end
        end
        function initializeNLPControlVariables(obj)
            obj.U = cell(1,obj.NumNodes);
            for i = 1:obj.NumNodes
                obj.U{i} = obj.Problem.variable(obj.NumControls);
            end
        end
        function collocationConstraints(obj)
            for i = 1:obj.NumNodes-1
                obj.defect(i);
            end
        end
        function t0 = getInitialTime(obj)
            if ~isempty(obj.InitialTime)
                t0 = obj.InitialTime;
                return;
            elseif ~isempty(obj.T0)
                t0 = obj.T0;
            else
                msg = "Initial time not set.";
                error(msg);
            end
        end
        function tf = getFinalTime(obj)
            if ~isempty(obj.FinalTime)
                tf = obj.FinalTime;
                return;
            elseif ~isempty(obj.Tf)
                tf = obj.Tf;
            else
                msg = "Final time not set.";
                error(msg);
            end
        end
        function [t0,tf] = getTimes(obj)
            t0 = obj.getInitialTime();
            tf = obj.getFinalTime();
        end
        function setTime(obj)
            [t0,tf] = obj.getTimes();
            obj.Time = linspace(t0,tf,obj.NumNodes);
        end
        function t = interpolateTime(obj)
            t = zeros(1,(obj.NumNodes - 1)*obj.ns);
            for i = 1:obj.NumNodes - 1
                t0 = obj.Time(i);
                tf = obj.Time(i + 1);
                t((i - 1)*obj.ns + 1:i*obj.ns) = linspace(t0,tf,obj.ns);
            end 
        end
    end
    methods (Access = protected, Abstract)
        defect(obj,i);
        interpolateState(obj,i);
        interpolateControl(obj,i);
    end
end