close("all"); clear; clc;
path = "C:\Users\marti\trajopt\examples\sharpmotorcycle\Experiments\Chicane\";

params = [
    bigSportsParameters();
    cruiserParameters();
    touringParameters();
];

state = SharpMotorcycleState();
state.setInitial("Offset",nan);
state.setFinal("Offset",nan);
state.setMin("Offset",-3.5);
state.setMax("Offset",0);

state.setMin("Relative heading",-deg2rad(90));
state.setMax("Relative heading",deg2rad(90));

state.setMin("Lean",-deg2rad(60));
state.setMax("Lean",deg2rad(60));

state.setMin("Steering torque",-200);
state.setMax("Steering torque",200);

input = SharpMotorcycleInput();
input.setInitial("Steering torque rate",nan);
input.setFinal("Steering torque rate",nan);
input.setMin("Steering torque rate",-100);
input.setMax("Steering torque rate",100);

v = 80/3.6;
scen = chicaneScenario();
g = @LegendreGaussRadau;
f = @(p)SharpMotorcycleExperiment(g,38,v,scen,state,input,p).run();
results = arrayfun(f,params);

% save(path + "chicane_results.mat","results");