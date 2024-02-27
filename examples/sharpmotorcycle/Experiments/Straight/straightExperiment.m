function results = straightExperiment(N,parameters)
    arguments
        N (1,1) double {mustBeInteger, mustBeReal, mustBePositive};
        parameters (1,1) BikeSimMotorcycleParameters;
    end
    v = 130/3.6;
    curvature = 0;
    p = [
        v;
        curvature;
        bikeSimToSharp(parameters).list()
    ];

    prob = CollocationProblem(N);
    x0 = zeros(1,prob.NumNodes);

    t0 = FixedTime("s0",Unit("progress",'m'),0);
    tf = FixedTime("sf",Unit("progress",'m'),175);

    d = State(prob,'Offset',Unit("distance",'m'),x0,-3,3,-3.5,3.5);
    rel_head = State(prob,'Relative heading',Unit("angle",'rad'),x0,0,0,-deg2rad(90),deg2rad(90));
    lean = State(prob,'Lean',Unit("angle",'rad'),x0,0,0,-deg2rad(60),deg2rad(60));
    steer = State(prob,'Steer',Unit("angle",'rad'),x0,0,0);
    vy = State(prob,'Lateral velocity',Unit("speed",'m/s'),x0,0,0);
    yaw_rate = State(prob,'Yaw rate',Unit("speed",'rad/s'),x0,0,0);
    lean_rate = State(prob,'Lean rate',Unit("speed",'rad/s'),x0,0,0);
    steer_rate = State(prob,'Steer rate',Unit("angular speed",'rad/s'),x0,0,0);
    Yr = State(prob,'Rear tire lateral force',Unit("force",'N'),x0,0,0);
    Yf = State(prob,'Front tire lateral force',Unit("force",'N'),x0,0,0);
    Msteer = State(prob,'Steer torque',Unit("torque",'Nm'),x0,0,0,-200,200);

    X = [
        d;
        rel_head
        lean;
        steer;
        vy;
        yaw_rate;
        lean_rate;
        steer_rate;
        Yr;
        Yf;
        Msteer
        ];

    x = StateVector(X);

    Jsteer_units = Unit("torque rate",'Nm/s');
    Jsteer = State(prob,'Steer torque rate',Jsteer_units,x0,nan,nan,-100,100);
    u = StateVector(Jsteer);

    plant = Plant(prob,x,u,p,@sharpMotorcycleRoadRelative);

    J = @(x,u)(1/1E04).*[x(9,:),x(10,:)]*[x(9,:),x(10,:)].' + (1/2).*u*u.';
    objfun = Objective(plant,J,@(x0,t0,xf,tf)0.*tf);

    prog = LegendreGauss(prob,objfun,plant,t0,tf);
    prog.solve();

    s = prog.Time;
    x = prog.Plant.States.getValues();
    CollocationPoints = result(prog,s,x,v);
    s = prog.interpolateTime();
    Trajectory = result(prog,s,prog.interpolateState(s),v);
    [s,x] = prog.simulatePlant();
    Simulation = result(prog,s,x,v);

    results = struct( ...
        "Collocation",CollocationPoints, ...
        "Trajectory",Trajectory, ...
        "Simulation",Simulation ...
        );
end

function r = result(prog,s,x,vx)
    fdt = @(x,u)1./([1,0,0]*roadRelativeKinematics(x,u,0));
    ft = @(s,x)s.*fdt([s;x(1,:);x(2,:)],[vx + 0.*x(5,:);x(5,:);x(6,:)]);
    t = ft(s,x);
    idx = contains(prog.Plant.States.getUnits,"rad");
    x(idx,:) = rad2deg(x(idx,:));
    names = prog.Plant.States.getNames();
    units = strrep(prog.Plant.States.getUnits(),"rad","{\circ}");
    r = struct("Time",t,"Progress",s,"States",x,"Names",names,"Units",units);
end