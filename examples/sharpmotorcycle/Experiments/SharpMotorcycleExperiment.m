classdef SharpMotorcycleExperiment < handle
    properties (GetAccess = public, SetAccess = private)
        Problem;
        Scenario;
        Speed;
        Program;
    end 
    methods (Access = public)
        function obj = SharpMotorcycleExperiment(N,v,scen,states,inputs,params)
            arguments
                N (1,1) double {mustBePositive,mustBeInteger};
                v (1,1) double {mustBePositive};
                scen (1,1) Road;
                states (1,1) SharpMotorcycleState;
                inputs (1,1) SharpMotorcycleInput;
                params (1,1) BikeSimMotorcycleParameters;
            end
            obj.Problem = CollocationProblem(N);
            obj.Scenario = scen;
            obj.Speed = v;
            s_units = Unit("arclength",'m');
            s0 = FixedTime("s0",s_units,0);
            sf = FixedTime("sf",s_units,scen.Parameter(end));
            X = obj.toStateVector(states);
            U = obj.toStateVector(inputs);
            curvature = obj.setCurvature();
            plant = obj.setPlant(X,U,curvature,params);
            costfun = obj.setCost(plant);
            obj.Program = LegendreGauss(obj.Problem,costfun,plant,s0,sf);
        end
        function result = run(obj)
            obj.Program.solve();
            result = obj.packageResult();
        end
    end
    methods (Access = private)
        function X = toStateVector(obj,in)
            state_names = cellfun(@string,in.Table.Properties.RowNames);
            unit_names = table2array(in.Table(:,"Name"));
            units = table2array(in.Table(:,"Units"));
            x0 = table2array(in.Table(:,"Initial"));
            xf = table2array(in.Table(:,"Final"));
            xmin = table2array(in.Table(:,"Min"));
            xmax = table2array(in.Table(:,"Max"));
            X0 = zeros(1,obj.Problem.NumNodes);
            f = @(state,name,unit,x0,xf,xmax,xmin)State( ...
                obj.Problem, ...
                state, ...
                Unit(name,unit), ...
                X0, ...
                x0, ...
                xf, ...
                xmax, ...
                xmin ...
                );
            x = arrayfun(f,state_names,unit_names,units,x0,xf,xmin,xmax);
            X = StateVector(x);
        end
        function k = setCurvature(obj)
            N = obj.Problem.NumNodes - 2;
            tau = 0.5.*([-1,sort(roots(legpol(N))).',1] + 1);
            arclength = obj.Scenario.Parameter./obj.Scenario.Parameter(end);
            k = interp1(arclength,obj.Scenario.Curvature,tau);
        end
        function plant = setPlant(obj,x,u,curvature,params)
            p = bikeSimToSharp(params);
            sys = sharpMotorcycleStateSpaceFactory(obj.Speed,p); 

            % road relative kinematics
            frr = @roadRelativeKinematics;
            v = obj.Speed;
            fr = @(x,p)frr([0.*x(1,:);x(1:2,:)],[v + 0.*x(1,:);x(5:6,:)],p); 

            % progress rate
            fds = @(x,p)[1,0,0]*fr(x,p);

            %  lateral offset and relative heading ODEs
            fk = @(x,p)[zeros(2,1),eye(2)]*fr(x,p);

            % sharp model ODEs
            A = sys.a;
            B = sys.b;
            fsharp = @(x)A*x(3:end - 1,:) + B*x(end,:);

            % complete model
            f = @(x,u,p)(1./(fds(x,p))).*[
                fk(x,p);
                fsharp(x);
                u
                ];

            plant = Plant(obj.Problem,x,u,curvature,f);
        end
        function costfun = setCost(~,plant)
            Jvy = @(x,u)1E03.*x(5,:).^2;
            JY = @(x,u)(1/1E05).*(x(9,:) + x(10,:)).^2;
            Ju = @(x,u)(1/0.1E03).*u.^2;
            J = @(x,u)Jvy(x,u) + JY(x,u) + Ju(x,u);
            costfun = Objective(plant,J,@(x0,t0,xf,tf)0.*tf);
        end
        function result = getResult(obj,s,x)
            % compute time from progress rate
            xk = [
                s;
                x(1:2,:)
                ];

            uk = [
                obj.Speed.*ones(size(s));
                x(5:6,:)
                ];

            scen = obj.Scenario;
            curvature = interp1(scen.Parameter,scen.Curvature,s);
            s_dot = [1,0,0]*roadRelativeKinematics(xk,uk,curvature);
            t = s./s_dot;

            % convert radian states and names to degrees
            idx = contains(obj.Program.Plant.States.getUnits(),"rad");
            x(idx,:) = rad2deg(x(idx,:));
            names = obj.Program.Plant.States.getNames();
            units = strrep(obj.Program.Plant.States.getUnits(),"rad","{\circ}");

            % package results
            result = struct("Time",t, ...
                "Progress",s, ...
                "States",x, ...
                "Names",names, ...
                "Units",units ...
                );
        end
        function result = getCollocationResult(obj)
            s = obj.Program.Time;
            x = obj.Program.Plant.States.getValues();
            result = obj.getResult(s,x);
        end
        function result = getInterpolationResult(obj)
            s = obj.Program.interpolateTime();
            x = obj.Program.interpolateState(s);
            result = obj.getResult(s,x);
        end
        function result = packageResult(obj)
            result = struct( ...
                "Collocation",obj.getCollocationResult(), ...
                "Trajectory",obj.getInterpolationResult() ...
                );
        end
    end 
end