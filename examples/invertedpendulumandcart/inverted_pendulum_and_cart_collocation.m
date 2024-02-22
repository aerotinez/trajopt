close("all"); clear; clc;

g = -9.81;
l = 0.3;
mc = 0.5;
mp = 0.2;
params = [g,l,mc,mp].';

prob = CollocationProblem(50);
x0 = zeros(1,prob.NumNodes);

t0 = FixedTime('t0',Unit("time",'s'),0);
tf = FreeTime(prob,'tf',Unit("time",'s'),10,0);

p = State(prob,'x',Unit("position",'m'),x0,1,3);
theta = State(prob,'\theta',Unit("angle",'rad'),x0,deg2rad(180),0);
v = State(prob,"v_x",Unit("speed","m/s"),x0,0,0);
w = State(prob,"\omega_y",Unit("speed","rad/s"),x0,0,0);
x = StateVector([p,theta,v,w].');

force = State(prob,"force",Unit("force","N"),x0,nan,nan,-50,50);
u = StateVector(force.');

plant = Plant(prob,x,u,params,@invertedPendulumAndCart);

gamma = 1;
objfun = Objective(plant,@(x,u) 0,@(x0,t0,xf,tf)gamma*tf);
 
prog = LegendreGauss(prob,objfun,plant,t0,tf,2);
prog.solve();
% prog.plotState(2,2);
% prog.plotControl(1,1);