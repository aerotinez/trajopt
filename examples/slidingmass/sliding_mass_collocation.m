close("all"); clear; clc;

%% Problem
N = 23;
prog = trajopt.collocation.lgr(N,-1);
prog.setInitialTime(0);
prog.setFinalTime();

%% States
names = ["Position","Velocity"]';
quantities = ["distance","speed"]';
units = ["m","m/s"]';
x0 = [0,0]';
xf = [1,0]';
lb = [0,-10]';
ub = [1,10]';

states = trajopt.vartable(names, ...
    'Quantity',quantities, ...
    'Units',units, ...
    'InitialValue',x0, ...
    'FinalValue',xf, ...
    'LowerBound',lb, ...
    'UpperBound',ub ...
    );

prog.setStates(states);

%% Controls
names = "Force";
quantities = "force";
units = "N";
x0 = nan;
xf = nan;
lb = -100;
ub = 100;

controls = trajopt.vartable(names, ...
    'Quantity',quantities, ...
    'Units',units, ...
    'InitialValue',x0, ...
    'FinalValue',xf, ...
    'LowerBound',lb, ...
    'UpperBound',ub ...
    );

prog.setControls(controls);

%% Parameters
Mass = ones(N,1);
prog.setParameters(table(Mass));

%% Plant
prog.setPlant(@slidingMass);

%% Objective
prog.setObjective(@(x,u,p)(1/2)*u.^2,@(x0,t0,xf,tf)tf);

%% Solve
prog.solve();

%% Trajectory
traj = trajopt.trajectory.lgps(prog,@slidingMass,states,controls);
fig = plot(traj,1,3);
fig.Position = [100,300,1080,240];
