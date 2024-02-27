close("all"); clear; clc;
path = "C:\Users\marti\trajopt\examples\sharpmotorcycle\Experiments\Straight\";

params = [
    bigSportsParameters();
    cruiserParameters();
    touringParameters();
];

f = @(p)straightExperiment(10,p);
results = arrayfun(f,params);
save(path + "straight_results.mat","results");