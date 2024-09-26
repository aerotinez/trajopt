close("all"); clear; clc;
cd(fileparts(mfilename("fullpath")));

params = [
    bigSportsParameters();
    cruiserParameters();
    touringParameters();
];

state = sharpMotorcycleExtendedState();
state{"Offset","Initial"} = -1.75;
state{"Offset","Final"} = 1.75;
state{"Offset","Min"} = -3.5;
state{"Offset","Max"} = 3.5;
 
state{"Relative heading","Min"} = -deg2rad(90);
state{"Relative heading","Max"} = deg2rad(90);

state{"Lean","Min"} = -deg2rad(60);
state{"Lean","Max"} = deg2rad(60);

v = 80/3.6;
state{"Longitudinal speed","Initial"} = v;
state{"Longitudinal speed","Final"} = v;
state{"Longitudinal speed","Min"} = 30/3.6;
state{"Longitudinal speed","Max"} = 130/3.6;

state{"Throttle torque","Min"} = -10000;
state{"Throttle torque","Max"} = 10000;

state{"Steering torque","Min"} = -200;
state{"Steering torque","Max"} = 200;

input = sharpMotorcycleExtendedInput();
input{"Steering torque rate","Min"} = -100;
input{"Steering torque rate","Max"} = 100;

scen = straightScenario();
prob = CollocationProblem(6);
h = @LegendreGaussRadau;
model = @(p)sharpMotorcycleExtendedFactory(p);
cost = @(p)sharpMotorcycleExtendedCostFunction(model(p),p);
f = @(p)SharpMotorcycleExtendedExperiment(prob,h,model(p),cost(p),scen,state,input).run();
results = arrayfun(f,params);

save(path + "extended_straight_results.mat","results");