close("all"); clear; clc;

g = 9.81;
m = 7;
r = 0.297;
params = [g,m,r].';
d = 150;
v = 110/3.6;
t_est = d/v;
w = v/r;

prob = CollocationProblem(50);
q0 = zeros(1,prob.NumNodes);

t0 = Time('t0',Unit("time",'s'),0);
tf = Time(prob,'tf',Unit("time",'s'),t_est,0);

x = State(prob,'x',Unit("position",'m'),q0,0,d);
y = State(prob,'y',Unit("position",'m'),q0,0,3.5);
yaw = State(prob,"yaw",Unit("angle","rad"),q0,0,0);
lean = State(prob,"lean",Unit("angle","rad"),q0,0,0);
pitch = State(prob,"pitch",Unit("angle","rad"),q0,0);
q = CollocationVector([x,y,yaw,lean,pitch].');

yaw_rate = State(prob,"yaw rate",Unit("speed","rad/s"),q0,0,0);
lean_rate = State(prob,"lean rate",Unit("speed","rad/s"),q0,0,0);
pitch_rate = State(prob,"pitch rate",Unit("speed","rad/s"),0,w,w);
u = CollocationVector([yaw_rate,lean_rate,pitch_rate].');

Mx = State(prob,"lean torque",Unit("torque","Nm"),q0,[],[],-10,10);
My = State(prob,"pitch torque",Unit("torque","Nm"),q0,[],[],-10,10);
Mz = State(prob,"yaw torque",Unit("torque","Nm"),q0,[],[],-10,10);

F = CollocationVector([Mx,My,Mz].');
 
Jqd = @rollingDiskRateJacobian;
Ju = @rollingDiskSpeedJacobian;
Jdu = @rollingDiskSpeedJacobianRate;
fd = @rollingDiskDynamics;
plant = Plant(prob,q,u,F,params,Jqd,Ju,Jdu,fd);

gamma = 1;
fL = @(x,u) 0.*(1/2).*u.'*u;
fM = @(x0,t0,xf,tf)gamma*tf;
objfun = Objective(plant,fL,fM);

prog = HermiteSimpsonSecondOrder(prob,objfun,plant,t0,tf);
prog.solve();
prog.plotStateNodes(4,2);
prog.plotControlNodes(3,1);