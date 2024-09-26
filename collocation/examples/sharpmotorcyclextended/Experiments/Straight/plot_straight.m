close("all"); clear; clc;
load("straight_results.mat");
% fig_path = "C:\Users\marti\PhD\Articles\CDC24\Figures\";
fig_results = plotResults(results);
% saveas(fig_results,fig_path + "results_straight",'epsc');

% fig_road = plotScenario(straightScenario(),results);
% title("Straight scenario","Parent",fig_road.Children(end));
% saveas(fig_road,fig_path + "road_straight",'epsc');