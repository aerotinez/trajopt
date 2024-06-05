close("all"); clear; clc;
load("arc_results.mat");
fig_path = "C:\Users\marti\PhD\Articles\CDC24\Figures\";
fig_results = plotResults(results);
saveas(fig_results,fig_path + "results_arc",'epsc');

fig_road = plotScenario(arcScenario(),results);
view(fig_road.Children(end),-90,25);
title("Arc scenario","Parent",fig_road.Children(end));
saveas(fig_road,fig_path + "road_arc",'epsc');