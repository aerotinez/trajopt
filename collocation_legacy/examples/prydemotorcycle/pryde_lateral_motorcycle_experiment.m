close("all"); clear; clc;
cd(fileparts(mfilename('fullpath')));

%% Imports
dirs = [
    "objfun";
    "parameters";
    "prydeMotorcycleLateralStateSpace";
    "roadRelativeKinematicsDAE";
    "roads";
    "scenarios"
    ];

arrayfun(@addpath,dirs);

%% Constants
NUM_COLLOCATION_POINTS = 25;
SPEED = 50;
LANE_WIDTH = 3.5;

%% Scenario
scen = arcScenario;

%% Problem
prog = directcollocation.LegendreGaussRadau(NUM_COLLOCATION_POINTS,1);
prog.setInitialTime(0);
prog.setFinalTime(scen.Parameter(end));

%% Parameters
bike = bigSportsParameters;
params = bikeSimToPrydeParameters(bike,SPEED/3.6);
p = cell2mat(struct2cell(params));

x0 = stateCostTrim(p,ones(7,1));
w0 = trimWheelSpeeds(p);
d0 = -LANE_WIDTH/2;
vx0 = SPEED/3.6;
wr0 = w0(1);
wf0 = w0(2);

u0 = inputCostTrim(p,ones(3,1));
My0 = abs(u0(1));

%% States

names = [
    "Relative heading";
    "Offset";
    "Forward Speed"
    "Camber";
    "Steer";
    "Yaw rate (body-fixed)";
    "Side speed";
    "Roll rate (body-fixed)";
    "Steer rate (body-fixed)"
    ];

quantities = [
    "angle";
    "distance";
    "speed";
    "angle";
    "angle";
    "speed";
    "speed";
    "speed";
    "speed"
    ];

units = [
    "rad";
    "m";
    "m/s";
    "rad";
    "rad";
    "rad/s";
    "m/s";
    "rad/s";
    "rad/s"
    ];

x0 = [
    0;
    d0;
    SPEED/3.6;
    0;
    0;
    0;
    0;
    0;
    0
    ];

xf = -x0;
xf(3) = SPEED/3.6;

lb = [
    -inf;
    2*d0;
    1;
    -inf(6,1)
    ];

ub = -lb;
ub(3) = 150/3.6;

states = directcollocation.vartable(names, ...
    'Quantity',quantities, ...
    'Units',units, ...
    'InitialValue',x0, ...
    'FinalValue',xf, ...
    'LowerBound',lb, ...
    'UpperBound',ub ...
    );

prog.setStates(states);

%% Inputs

controls = directcollocation.vartable(["Steer torque","Throttle"], ...
    'Quantity',["torque","Force"], ...
    'Units',["Nm","N"], ...
    'InitialValue',[0,0], ...
    'FinalValue',[0,0], ...
    'LowerBound',[-50,-10], ...
    'UpperBound',[50,10] ...
    );

prog.setControls(controls);

%% Curvature
tau = ([-1,sort(roots(legpol(prog.NumNodes - 2))).',1] + 1)/2;
k = interp1(scen.Parameter/scen.Parameter(end),scen.Curvature,tau);

prog.setParameters(table(k(2:end)'));

%% Plant
M = prydeMotorcycleLateralSSMassMatrix(p);
H = @prydeMotorcycleLateralSSForcingMatrix;
G = prydeMotorcycleLateralSSInputMatrix(p);
fp = @(x)[p(1:14);x(3,:);p(16:end)];

A = @(p)M\H(p);
B = M\G;

rr = params.rr;
fRoadRel = @roadRelativeKinematicsForcingVector;
frr = @(x,p)fRoadRel([0*x(1,:);x(1:2,:)],[x(3,:);0.*x(1:2,:);x(4:end,:)],[p;rr]);
fs = @(x,p)[1,0,0]*frr(x,p);
fdr = @(x,p)[zeros(2,1),eye(2)]*frr(x,p);

f = @(x,u,p)(1/fs(x,p))*[
    fdr(x,p);
    u(2,:);
    A(fp(x))*x(4:end,:) + B*u(1,:)
    ];

prog.setPlant(f);

%% Objective
prog.setObjective(@(x,u,p)(1/2)*u(:)'*u(:),@(x0,t0,xf,tf)tf);

%% Solve
prog.solve();

%% Plotting
[t,x,u,p] = interpolate(prog);

xp = prog.Solution.value(prog.States)';

tl = tiledlayout(3,3);

for k = 1:9
    axe = nexttile(tl,k);
    hold(axe,'on');
    plot(axe,t,x(:,k));
    hold(axe,'off');
    axis(axe,'tight');
    box(axe,'on');
end

%% Cleanup
arrayfun(@rmpath,dirs);