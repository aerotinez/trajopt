close("all"); clear; clc;

prob = CollocationProblem(10);
x = CollocationVariable(prob,'y',Unit("position",'m'),zeros(1,11));
y = CollocationVariable(prob,'y',Unit("position",'m'),zeros(1,11));