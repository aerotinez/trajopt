close("all"); clear; clc;

g = 9.81;
m = 7;
r = 0.297;
params = [g,m,r].';
v = 1/3.6;
w = v/r;

prob = CollocationProblem(25);
q0 = zeros(1,prob.NumNodes);

t0 = TimeVariable('t0',Unit("time",'s'),0);
tf = TimeVariable(prob,'tf',Unit("time",'s'),260,0);

x = CollocationVariable(prob,'x',Unit("position",'m'),q0,0,100,0);
y = CollocationVariable(prob,'y',Unit("position",'m'),q0,0,1);
yaw = CollocationVariable(prob,"yaw",Unit("angle","rad"),q0,0,0);
lean = CollocationVariable(prob,"lean",Unit("angle","rad"),q0,0,0);
pitch = CollocationVariable(prob,"pitch",Unit("angle","rad"),q0,0);
q = CollocationVector([x,y,yaw,lean,pitch].');

yaw_rate = CollocationVariable(prob,"yaw rate",Unit("speed","rad/s"),q0,0,0);
lean_rate = CollocationVariable(prob,"lean rate",Unit("speed","rad/s"),q0,0,0);
pitch_rate = CollocationVariable(prob,"pitch rate",Unit("speed","rad/s"),q0,w,w);
u = CollocationVector([yaw_rate,lean_rate,pitch_rate].');

pitch_torque = CollocationVariable(prob,"pitch torque",Unit("torque","Nm"),q0,[],[],-0.05,0.05);
lean_torque = CollocationVariable(prob,"lean torque",Unit("torque","Nm"),q0,[],[],-1E-02,1E-02);
F = CollocationVector([pitch_torque,lean_torque].');
 
Jqd = @rollingDiskRateJacobian;
Ju = @rollingDiskSpeedJacobian;
Jdu = @rollingDiskSpeedJacobianRate;
fd = @rollingDiskDynamics;
plant = Plant(prob,q,u,F,params,Jqd,Ju,Jdu,fd);

gamma = 1;
fL = @(x,u) 0;
fM = @(x0,t0,xf,tf)gamma*tf;
objfun = CollocationObjective(plant,fL,fM);

prog = TrapezoidalSecondOrder(prob,objfun,plant,t0,tf);
prog.solve();
prog.plotStateNodes(4,2);
prog.plotControlNodes(2,1);