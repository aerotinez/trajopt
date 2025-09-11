close("all"); clear; clc;
cd(fileparts(mfilename('fullpath')));

%% Constants
NUM_COLLOCATION_POINTS = 38;
SPEED = 50;
LANE_WIDTH = 3.5;

%% Scenario
scen = arcScenario;

%% Problem
prog = trajopt.collocation.lgr(NUM_COLLOCATION_POINTS,1);
prog.setInitialTime(0);
prog.setFinalTime(scen.Parameter(end));

%% Parameters
bike = bigSportsParameters;
params = bikeSimToPrydeParameters(bike,SPEED/3.6);
p = cell2mat(struct2cell(params));
d0 = -(LANE_WIDTH/2 + 1.5);

%% States

names = [
    "Relative heading";
    "Offset";
    "Camber";
    "Steer";
    "Yaw rate (body-fixed)";
    "Lateral speed";
    "Roll rate (body-fixed)";
    "Steer rate (body-fixed)";
    "Steer torque"
    ];

quantities = [
    "angle";
    "distance";
    "angle";
    "angle";
    "speed";
    "speed";
    "speed";
    "speed";
    "torque"
    ];

units = [
    "rad";
    "m";
    "rad";
    "rad";
    "rad/s";
    "m/s";
    "rad/s";
    "rad/s";
    "Nm"
    ];

x0 = [
    0;
    d0;
    0;
    0;
    0;
    0;
    0;
    0;
    0
    ];

xf = x0;

lb = [
    -inf;
    -LANE_WIDTH;
    -inf(7,1)
    ];

ub = -lb;

states = trajopt.vartable(names, ...
    'Quantity',quantities, ...
    'Units',units, ...
    'InitialValue',x0, ...
    'FinalValue',xf, ...
    'LowerBound',lb, ...
    'UpperBound',ub ...
    );

prog.setStates(states);

%% Inputs

controls = trajopt.vartable("Steer torque rate", ...
    'Quantity',"torque rate", ...
    'Units',"Nm/s", ...
    'InitialValue',0, ...
    'FinalValue',nan, ...
    'LowerBound',-inf, ...
    'UpperBound',inf ...
    );

prog.setControls(controls);

%% Curvature
tau = (prog.Nodes(2:end) + 1)/2;
k = interp1(scen.Parameter/scen.Parameter(end),scen.Curvature,tau);

prog.setParameters(table(k'));

%% Plant
M = prydeMotorcycleLateralSSMassMatrix(p);
H = @prydeMotorcycleLateralSSForcingMatrix;
G = prydeMotorcycleLateralSSInputMatrix(p);
fp = @(x)p;

A = @(p)M\H(p);
B = M\G;

rr = params.rr;
fRoadRel = @roadRelativeKinematicsForcingVector;
frr = @(x,p)fRoadRel([0*x(1,:);x(1:2,:)],[params.v;0.*x(1:2,:);x(3:end - 1,:)],[p;rr]);
fs = @(x,p)[1,0,0]*frr(x,p);
fdr = @(x,p)[zeros(2,1),eye(2)]*frr(x,p);

f = @(x,u,p)(1/fs(x,p))*[
    fdr(x,p);
    A(fp(x))*x(3:end - 1,:) + B*x(end,:);
    u
    ];

prog.setPlant(f);

%% Objective
prog.setObjective(@(x,u,p)(1/fs(x,p))^2,@(x0,t0,xf,tf)0);

%% Solve
prog.solve();

%% Plotting
traj = trajopt.trajectory.lgps(prog,f,states,controls);
fig = plot(traj,5,2);
fig.Position = [100,50,1080,720];
