close("all"); clear; clc;

v = 130/3.6;
k = 0;
params = [
    v;
    k;
    sharpMotorcycle1971Parameters().list()
    ];

prob = CollocationProblem(13);
x0 = zeros(1,prob.NumNodes);

t0 = FixedTime("s0",Unit("progress",'m'),0);
tf = FreeTime(prob,"s0",Unit("progress",'m'),200,0);

d = State(prob,'offset',Unit("distance",'m'),x0,-3,0,-3.5,3.5);
rel_head = State(prob,'relative heading',Unit("angle",'rad'),x0,0,0);
lean = State(prob,'lean',Unit("angle",'rad'),x0,0,0);
steer = State(prob,'steer',Unit("angle",'rad'),x0,0,0);
vy = State(prob,'vy',Unit("speed",'m/s'),x0,0,0);
yaw_rate = State(prob,'yaw rate',Unit("angular speed",'rad/s'),x0,0,0);
lean_rate = State(prob,'lean rate',Unit("angular speed",'rad/s'),x0,0,0);
steer_rate = State(prob,'steer rate',Unit("angular speed",'rad/s'),x0,0,0);
Yr = State(prob,'Rear tire lateral force',Unit("force",'N'),x0);
Yf = State(prob,'Front tire lateral force',Unit("force",'N'),x0);
Msteer = State(prob,'Steering torque',Unit("torque",'Nm'),x0);

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

Jsteer = State(prob,'Steering torque rate',Unit("torque rate",'Nm/s'),x0,nan,nan,-75,75);
u = StateVector(Jsteer);

plant = Plant(prob,x,u,params,@sharpMotorcycleRoadRelative);

gamma = 0;
J = @(x,u)(1./((v.*cos(x(2,:)) + x(5,:).*sin(x(2,:)))./(k.*x(1,:) - 1))).^2;
objfun = Objective(plant,J,@(x0,t0,xf,tf)gamma*tf);

prog = LegendreGauss(prob,objfun,plant,t0,tf);
prog.solve();
prog.plotState(4,3);
prog.plotControl(1,1);