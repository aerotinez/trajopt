function results = arcExperiment(scenario,degree,parameters)
    arguments
        scenario (1,1) Road;
        degree (1,1) double {mustBeInteger, mustBeReal, mustBePositive};
        parameters (1,1) BikeSimMotorcycleParameters;
    end

    prob = CollocationProblem(degree);
    x0 = zeros(1,prob.NumNodes);

    tau = 0.5.*[-1,sort(roots(legpol(prob.NumNodes - 2))).',1] + 0.5;
    s = scenario.Parameter./scenario.Parameter(end);
    curvature = interp1(s,scenario.Curvature,tau);

    v = 80/3.6;
    p = [
        repmat(v,[1,prob.NumNodes]);
        curvature;
    ];

    t0 = FixedTime("s0",Unit("progress",'m'),0);
    tf = FixedTime("sf",Unit("progress",'m'),scenario.Parameter(end));

    d = State(prob,'Offset',Unit("distance",'m'),x0,0,0,-3.5,3.5);
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

    params = bikeSimToSharp(parameters).list();
    A = sharpMotorcycleRoadRelativeFactory(params);
    f = @(x,u,p)A(x,u,p)*x;
    plant = Plant(prob,x,u,p,f);

    J = @(x,u)(1/2).*u*u.';
    objfun = Objective(plant,J,@(x0,t0,xf,tf)0.*tf);

    prog = LegendreGauss(prob,objfun,plant,t0,tf);
    prog.solve();

    s = prog.Time;
    x = prog.Plant.States.getValues();
    CollocationPoints = result(prog,s,x,v);
    s = prog.interpolateTime();
    Trajectory = result(prog,s,prog.interpolateState(s),v);

    results = struct( ...
        "Collocation",CollocationPoints, ...
        "Trajectory",Trajectory ...
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