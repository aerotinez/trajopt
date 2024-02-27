close("all"); clear; clc;
path = "C:\Users\marti\trajopt\examples\sharpmotorcycle\Experiments\Arc\";

scenario = arcScenario();

params = [
    bigSportsParameters();
    cruiserParameters();
    touringParameters();
];

f = @(p)arcExperiment(scenario,20,p);
results = arrayfun(f,params);
save(path + "arc_results.mat","results");