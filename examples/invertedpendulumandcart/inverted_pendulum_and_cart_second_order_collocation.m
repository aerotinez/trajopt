close("all"); clear; clc;

g = -9.81;
l = 0.3;
mc = 0.5;
mp = 0.2;
params = [g,l,mc,mp].';

prob = CollocationProblem(50);
q0 = zeros(1,prob.NumNodes);

t0 = FixedTime('t0',Unit("time",'s'),0);
tf = FreeTime(prob,'tf',Unit("time",'s'),10,0);

p = State(prob,'x',Unit("position",'m'),q0,1,5,0,10);
theta = State(prob,'theta',Unit("angle",'rad'),q0,deg2rad(180),0);
q = StateVector([p;theta]);

v = State(prob,"v_x",Unit("speed","m/s"),q0,0,0);
w = State(prob,"\omega_y",Unit("speed","rad/s"),q0,0,0);
u = StateVector([v,w].');

force = State(prob,"force",Unit("force","N"),q0,nan,nan,-50,50);
F = StateVector(force.');

fr = @(q,qr,p)qr;
fk = @(q,u,p)u;
fd = @(q,u,F,p)[zeros(2),eye(2)]*invertedPendulumAndCart([q;u],F,p);
plant = Plant(prob,q,u,F,params,fr,fk,fd);

gamma = 1;
fL = @(x,u) 0;
fM = @(x0,t0,xf,tf)gamma*tf;
objfun = Objective(plant,fL,fM);
 
prog = TrapezoidalSecondOrder(prob,objfun,plant,t0,tf);
prog.solve();
prog.plotStateNodes(2,2);
prog.plotControlNodes(1,1);