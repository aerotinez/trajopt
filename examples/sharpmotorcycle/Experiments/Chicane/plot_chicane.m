close("all"); clear; clc;
load("chicane_results.mat");
fig_path = "C:\Users\marti\PhD\Articles\CDC24\Figures\";
fig_results = plotResults(results);
saveas(fig_results,fig_path + "results_chicane",'epsc');

fig_road = plotScenario(chicaneScenario(),results);
view(fig_road.Children(end),-90,5);
title("Chicane scenario","Parent",fig_road.Children(end));
saveas(fig_road,fig_path + "road_chicane",'epsc');