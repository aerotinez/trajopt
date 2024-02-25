close("all"); clear; clc;

v = 130/3.6;
k = 0;
params = [v;k];

prob = CollocationProblem(17);
x0 = zeros(1,prob.NumNodes);

t0 = FixedTime("s0",Unit("progress",'m'),0);
tf = FixedTime("s0",Unit("progress",'m'),200);

d = State(prob,'offset',Unit("distance",'m'),x0,-3,3,-3.5,3.5);
rel_head = State(prob,'relative heading',Unit("angle",'rad'),x0,0,0);
lean = State(prob,'lean',Unit("angle",'rad'),x0,0,0);
steer = State(prob,'steer',Unit("angle",'rad'),x0,0,0);
vy = State(prob,'vy',Unit("speed",'m/s'),x0,0,0,-5,5);
yaw_rate = State(prob,'yaw rate',Unit("angular speed",'rad/s'),x0,0,0);
lean_rate = State(prob,'lean rate',Unit("angular speed",'rad/s'),x0,0,0);
steer_rate = State(prob,'steer rate',Unit("angular speed",'rad/s'),x0,0,0);
Yr = State(prob,'Rear tire lateral force',Unit("force",'N'),x0);
Yf = State(prob,'Front tire lateral force',Unit("force",'N'),x0);

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
    Yf
    ];

x = StateVector(X);

Msteer = State(prob,'Steering torque',Unit("torque",'Nm'),x0,nan,nan,-50,50);
u = StateVector(Msteer);

A = @(x,p)sharpMotorcycleLPVStateMatrix([p(1),x(1),x(2),p(2)].');
B = @(x,p)sharpMotorcycleLPVInputMatrix([p(1),x(1),x(2),p(2)].');
plant = Plant(prob,x,u,params,@(x,u,p)A(x,p)*x + B(x,p)*u);

gamma = 0;
J = @(x,u)((x(9) + x(10))./((v.*cos(x(2)) + x(5).*sin(x(2)))./(k.*x(1) - 1))).^2;
objfun = Objective(plant,J,@(x0,t0,xf,tf)gamma*tf);

prog = LegendreGauss(prob,objfun,plant,t0,tf);
prog.solve();
prog.plotState(4,3);
prog.plotControl(1,1);