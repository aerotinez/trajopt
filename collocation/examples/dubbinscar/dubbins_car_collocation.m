close("all"); clear; clc;

v = 10;
params = v;

prob = CollocationProblem(35);
x0 = zeros(1,prob.NumNodes);

t0 = FixedTime('t0',Unit("time",'s'),0);
tf = FreeTime(prob,'tf',Unit("time",'s'),10,0);

px = State(prob,'x',Unit("position",'m'),x0,0,10);
py = State(prob,'y',Unit("position",'m'),x0,0,10);
yaw = State(prob,'\psi',Unit("angle",'rad'),x0,0,0);
yaw_rate = State(prob,'\omega_\psi',Unit("speed",'rad/s'),x0,0,0);
x = StateVector([px,py,yaw,yaw_rate].');

u_units = Unit("acceleration","rad/s^2");
yaw_accel = State(prob,"\alpha_\psi",u_units,x0,nan,nan,-1E03,1E03);
u = StateVector(yaw_accel.');

plant = Plant(prob,x,u,params,@dubbinsCar);

R = 1E-04;
objfun = Objective(plant,@(x,u,p)u.'*R*u,@(x0,t0,xf,tf)tf);

prog = LegendreGaussRadau(prob,objfun,plant,t0,tf);
prog.solve();
prog.plotState(2,2);
prog.plotControl(1,1);

x_out = prog.interpolateState(linspace(0,prog.FinalTime.Value,1E03));
fig = figure();
axe = axes(fig);
plot(x_out(1,:),x_out(2,:),'k',"LineWidth",2);
axis(axe,"equal");
box(axe,"on");
xlabel(axe,"x (m)");
ylabel(axe,"y (m)");