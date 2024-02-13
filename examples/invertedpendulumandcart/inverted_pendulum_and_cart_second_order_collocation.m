close("all"); clear; clc;

g = 9.81;
l = 0.3;
mc = 0.5;
mp = 0.2;
params = [g,l,mc,mp].';

prob = CollocationProblem(100);
q0 = zeros(1,prob.NumNodes);

t0 = TimeVariable('t0',Unit("time",'s'),0);
tf = TimeVariable(prob,'tf',Unit("time",'s'),10,0);

p = CollocationVariable(prob,'x',Unit("position",'m'),q0,1,5,0,10);
theta = CollocationVariable(prob,'theta',Unit("angle",'rad'),q0,0,0);
q = CollocationVector([p,theta].');

v = CollocationVariable(prob,"v_x",Unit("speed","m/s"),q0,0,0);
w = CollocationVariable(prob,"omega_y",Unit("speed","rad/s"),q0,0,0);
u = CollocationVector([v,w].');

force = CollocationVariable(prob,"force",Unit("force","N"),q0,[],[],-100,100);
F = CollocationVector(force.');
 
Jqd = @(q,p)eye(2);
Ju = @(q,p)eye(2);
Jdu = @(q,u,p)zeros(2);
fd = @(q,u,F,p)[zeros(2),eye(2)]*invertedPendulumAndCart([q;u],F,p);
plant = Plant(prob,q,u,F,params,Jqd,Ju,Jdu,fd);

gamma = 1;
fL = @(x,u) 0;
fM = @(x0,t0,xf,tf)gamma*tf;
objfun = CollocationObjective(plant,fL,fM);

prog = TrapezoidalSecondOrder(prob,objfun,plant,t0,tf);
prog.solve();
prog.plotStateNodes(2,2);
prog.plotControlNodes(1,1);