close("all"); clear; clc;
fig_path = "C:\Users\marti\PhD\Articles\CDC24\Figures\";
straight = straightScenario();
arc = arcScenario();
chicane = chicaneScenario();

scens = [
    straight;
    arc;
    chicane
    ];

titles = [
    "Straight";
    "Arc";
    "Chicane"
    ];

fig = figure();
tiledlayout(fig,1,3);
for i = 1:numel(scens)
    nexttile;
    plot(scens(i).Parameter,scens(i).Curvature,'k',"LineWidth",2);
    axe = gca;
    axe.FontSize = 12;
    title(titles(i));
    xlim([0,max(scens(i).Parameter)]);
    xlabel("arclength (m)");
    ylabel("curvature (1/m)");
end
fig.Position = [100,300,720,180];
saveas(fig,fig_path + "curvature",'epsc');