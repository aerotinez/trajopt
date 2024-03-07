close("all"); clear; clc;
path = "C:\Users\marti\trajopt\examples\sharpmotorcycle\Experiments\Arc\";

params = [
    bigSportsParameters();
    cruiserParameters();
    touringParameters();
];

state = SharpMotorcycleState();
state.setInitial("Offset",0);
state.setFinal("Offset",0);
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

v = 80/3.6;
scen = arcScenario();
f = @(p)SharpMotorcycleExperiment(22,v,scen,state,input,p).run();
results = arrayfun(f,params);

save(path + "arc_results.mat","results");