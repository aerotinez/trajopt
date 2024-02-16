close("all"); clear; clc;

Cdelta = 6.77;
Cf1 = 11174;
Cf2 = 938.6;
Cr1 = 15831;
Cr2 = 1325.6;
Crxz = -1.7355;
Ifx = 1.2338;
Ifz = 0.4420;
Irx = 31.18;
Iry = 0;
Irz = 21.07;
Zf = -1005.3;
Zr = -2400.7;
a = 0.9485376;
an = 0.1158;
b = 0.4798;
e = 0.0244;
f = 0.0283;
g = 9.81;
h = 0.6157;
ify = 0.7186;
iry = 1.0508;
mf = 30.65;
mr = 217.45;
rf = 0.3048;
rr = 0.3048;
sigma = 0.2438;
varepsilon = 0.4715;

params = [
    Cdelta;
    Cf1;
    Cf2;
    Cr1;
    Cr2;
    Crxz;
    Ifx;
    Ifz;
    Irx;
    Iry;
    Irz;
    Zf;
    Zr;
    a;
    an;
    b;
    e;
    f;
    g;
    h;
    ify;
    iry;
    mf;
    mr;
    rf;
    rr;
    sigma;
    varepsilon
    ];

prob = CollocationProblem(15);
x0 = zeros(1,prob.NumNodes);

t0 = FixedTime("t0",Unit("time",'s'),0);
tf = FreeTime(prob,"tf",Unit("time",'s'),10,0);

px = State(prob,'x',Unit("position",'m'),x0,0,150);
py = State(prob,'y',Unit("position",'m'),x0,0,1.75);
yaw = State(prob,'yaw',Unit("angle",'rad'),x0,0,0);
lean = State(prob,'lean',Unit("angle",'rad'),x0,0,0);
steer = State(prob,'steer',Unit("angle",'rad'),x0,0,0);
pitch_r = State(prob,'rear pitch',Unit("angle",'rad'),x0);
yaw_f = State(prob,'front yaw',Unit("angle",'rad'),x0,0);
lean_f = State(prob,'front lean',Unit("angle",'rad'),x0,0);
pitch_f = State(prob,'front pitch',Unit("angle",'rad'),x0,0);
vx = State(prob,'vx',Unit("speed",'m/s'),110/3.6,110/3.6,110/3.6,1);
vy = State(prob,'vy',Unit("speed",'m/s'),x0,0,0);
yaw_rate = State(prob,'yaw rate',Unit("angular speed",'rad/s'),x0,0,0);
lean_rate = State(prob,'lean rate',Unit("angular speed",'rad/s'),x0,0,0);
steer_rate = State(prob,'steer rate',Unit("angular speed",'rad/s'),x0,0,0);
Yr = State(prob,'Yr',Unit("force",'N'),x0);
Yf = State(prob,'Yf',Unit("force",'N'),x0);

X = [
    px;
    py;
    yaw;
    lean;
    steer;
    pitch_r;
    yaw_f;
    lean_f;
    pitch_f;
    vx;
    vy;
    yaw_rate;
    lean_rate;
    steer_rate;
    Yr;
    Yf
    ];

x = StateVector(X);

steer_torque = State(prob,'steer_torque',Unit("torque",'Nm'),x0,nan,nan,-50,50);
u = StateVector(steer_torque);

plant = Plant(prob,x,u,params,@sharpMotorcycle);

gamma = 1;
objfun = Objective(plant,@(x,u) 0,@(x0,t0,xf,tf) gamma*tf);