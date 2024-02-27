close("all"); clear; clc;
path = "C:\Users\marti\trajopt\examples\sharpmotorcycle\Experiments\Chicane\";

scenario = chicaneScenario();

params = [
    bigSportsParameters();
    cruiserParameters();
    touringParameters();
];

f = @(p)chicaneExperiment(scenario,20,p);
results = arrayfun(f,params);
save(path + "chicane_results.mat","results");