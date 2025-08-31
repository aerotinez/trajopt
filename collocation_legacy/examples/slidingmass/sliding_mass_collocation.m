close("all"); clear; clc;

%% Problem
N = 13;
prog = directcollocation.LegendreGauss(N);
prog.setInitialTime(0);
prog.setFinalTime();

%% States
names = ["Position","Velocity"]';
quantities = ["distance","speed"]';
units = ["m","m/s"]';
x0 = [0,0]';
xf = [1,0]';
lb = [0,-inf]';
ub = [1,1]';

states = directcollocation.vartable(names, ...
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
x0 = 0;
xf = 0;
lb = -20;
ub = 20;

controls = directcollocation.vartable(names, ...
    'Quantity',quantities, ...
    'Units',units, ...
    'InitialValue',x0, ...
    'FinalValue',xf, ...
    'LowerBound',lb, ...
    'UpperBound',ub ...
    );

prog.setControls(controls);

%% Parameters
Mass = 500*ones(N,1);
prog.setParameters(table(Mass));

%% Plant
prog.setPlant(@slidingMass);

%% Objective
prog.setObjective(@(x,u,p)(1/2)*u(:)'*u(:),@(x0,t0,xf,tf)tf);

%% Solve
prog.solve();

%% Plotting
[t,x,u,p] = interpolate(prog);

tl = tiledlayout(2,1);

for k = 1:2
    axe = nexttile(tl,k);
    plot(t,x(:,k));
    axis(axe,'tight');
    box(axe,'on');
end