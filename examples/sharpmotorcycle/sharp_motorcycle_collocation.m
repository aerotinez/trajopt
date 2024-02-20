close("all"); clear; clc;

params = [110/3.6;0];

prob = CollocationProblem(100);
x0 = zeros(1,prob.NumNodes);

t0 = FixedTime("s0",Unit("progress",'m'),0);
tf = FixedTime("sf",Unit("progress",'m'),200);

d = State(prob,'offset',Unit("distance",'m'),x0,0,3);
rel_head = State(prob,'relative heading',Unit("angle",'rad'),x0,0,0);
lean = State(prob,'lean',Unit("angle",'rad'),x0,0,0);
steer = State(prob,'steer',Unit("angle",'rad'),x0,0,0);
vy = State(prob,'vy',Unit("speed",'m/s'),x0,0,0);
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

steer_torque = State(prob,'steer torque',Unit("torque",'Nm'),x0,nan,nan,-50,50);
u = StateVector(steer_torque);

A = @(x,p)sharpMotorcycleLPVStateMatrix(p(1),x(1),x(2),p(2));
B = @(x,p)sharpMotorcycleLPVInputMatrix(p(1),x(1),x(2),p(2));
plant = Plant(prob,x,u,params,@(x,u,p)A(x,p)*x + B(x,p)*u);

gamma = 1;
objfun = Objective(plant,@(x,u) (1/2).*u.'*u,@(x0,t0,xf,tf) 0);

prog = HermiteSimpson(prob,objfun,plant,t0,tf);
prog.solve();
prog.plotState(5,2);
prog.plotControl(1,1);