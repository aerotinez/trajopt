close("all"); clear; clc;
path = "C:\Users\marti\trajopt\collocation\examples\sharpmotorcycle\Experiments\Straight\";

params = [
    bigSportsParameters();
    cruiserParameters();
    touringParameters();
];

state = SharpMotorcycleState();
state.setInitial("Offset",-1.75);
state.setFinal("Offset",1.75);
state.setMin("Offset",-3.5);
state.setMax("Offset",3.5);

state.setMin("Relative heading",-deg2rad(90));
state.setMax("Relative heading",deg2rad(90));

state.setMin("Lean",-deg2rad(60));
state.setMax("Lean",deg2rad(60));

state.setMin("Steering torque",-200);
state.setMax("Steering torque",200);

input = SharpMotorcycleInput();
input.setMin("Steering torque rate",-100);
input.setMax("Steering torque rate",100);

v = 130/3.6;
scen = straightScenario();
g = @LegendreGaussRadau;
f = @(p)SharpMotorcycleExperiment(g,38,v,scen,state,input,p).run();
results = arrayfun(f,params);

save(path + "straight_results.mat","results");