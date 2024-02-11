close("all"); clear; clc;

prob = CollocationProblem(10);
q0 = zeros(1,prob.NumNodes);

t0 = TimeVariable('t0',Unit("time",'s'),0);
tf = TimeVariable(prob,'tf',Unit("time",'s'),30,0);

x = CollocationVariable(prob,'x',Unit("position",'m'),q0);
y = CollocationVariable(prob,'y',Unit("position",'m'),q0);
yaw = CollocationVariable(prob,"yaw",Unit("angle","rad"),q0);
lean = CollocationVariable(prob,"lean",Unit("angle","rad"),q0);
pitch = CollocationVariable(prob,"pitch",Unit("angle","rad"),q0);
q = CollocationVector([x,y,yaw,lean,pitch].');

yaw_rate = CollocationVariable(prob,"yaw rate",Unit("speed","rad/s"),q0);
lean_rate = CollocationVariable(prob,"lean rate",Unit("speed","rad/s"),q0);
pitch_rate = CollocationVariable(prob,"pitch rate",Unit("speed","rad/s"),q0);
u = CollocationVector([yaw_rate,lean_rate,pitch_rate].');

pitch_torque = CollocationVariable(prob,"pitch torque",Unit("torque","Nm"),q0);
lean_torque = CollocationVariable(prob,"lean torque",Unit("torque","Nm"),q0);
F = CollocationVector([pitch_torque,lean_torque].');

params = zeros(3,prob.NumNodes);
 
fk = @rollingDiskKinematics;
fkd = @rollingDiskKinematicRates;
fd = @rollingDiskDynamics;
plant = Plant(prob,q,u,F,params,fk,fkd,fd);

fL = @(x,u) 1;
objfun = CollocationObjective(plant,fL);

prog = SecondOrderCollocation(prob,objfun,plant,t0,tf);
prog.plotStateNodes(4,2);
prog.plotControlNodes(2,1);