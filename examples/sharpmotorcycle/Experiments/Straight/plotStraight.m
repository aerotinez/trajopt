close("all"); clear; clc;
load("straight_results.mat");

bike_names = [
    "big sports";
    "cruiser";
    "touring"
    ];

line_names = [
    "collocation";
    "trajectory";
    "simulated"
    ];

fig = figure();
tiledlayout(fig,2,3);
arrayfun(@nexttile,1:prod(fig.Children.GridSize));

state_names = [
    "Offset";
    "Relative heading";
    "Lean";
    "Lateral velocity";
    "Lean rate";
    "Steer torque";
    ];

colors = 'krb';

arrayfun(@(r,c)plotResult(fig,r,state_names,c),results,colors.');
leg_names = {'','','big sports','','','cruiser','','','touring'};
leg = legend(leg_names{:}, ...
    "NumColumns",3, ...
    "Location","SouthOutside", ...
    "Box","on");
leg.Layout.Tile = 'south';

rd = Road();
road_length = results(3).Collocation.Progress(end);
rd.AddStraightSegment(road_length);
rd.Show();
fig_road = gcf;
arrayfun(@(r,c)plotRoad(fig_road,r,c),results,colors.');
axe_road = gca;
view(-60,25);
xlim([0,road_length]);
ylim([-7,7]);
zlim([0,3.5]);
camproj(axe_road,"perspective");
title(axe_road,"Straight road scenario");
daspect(axe_road,[5,1,1]);
leg_road_names = {'','','','','','big sports','','','cruiser','','','touring'};
leg_road = legend(leg_road_names{:}, ...
    "NumColumns",3, ...
    "Location","SouthOutside", ...
    "Box","on");

function fig = plotResult(fig,result,state_names,color)
    n = prod(fig.Children.GridSize);
    nx = size(result.Collocation.States,1);
    idx = nonzeros(contains(result.Collocation.Names,state_names).*(1:nx).');
    for i = 1:n
        axe = fig.Children.Children(n - i + 1);
        hold(axe,"on");
        t_collocation = result.Collocation.Time;
        x_collocation = result.Collocation.States(idx(i),:);
        scatter(t_collocation,x_collocation,20,color,"filled","Parent",axe);
        t_trajectory = result.Trajectory.Time;
        x_trajectory = result.Trajectory.States(idx(i),:);
        plot(t_trajectory,x_trajectory,color + "--","Parent",axe);
        t_simulation = result.Simulation.Time;
        x_simulation = result.Simulation.States(idx(i),:);
        plot(t_simulation,x_simulation,color,"Parent",axe); 
        hold(axe,"off");
        box(axe,"on");
        title(axe,result.Collocation.Names(idx(i)));
        xlabel(axe,"time (s)");
        ylabel(axe,result.Collocation.Units(idx(i)),'Interpreter','tex');
        xlim(axe,[0,t_simulation(end)]);
    end
end

function fig = plotRoad(fig,result,color)
    hold(fig.Children,"on");
    r = result.Trajectory;
    x0 = r.Progress;
    y0 = r.States(1,:);
    z0 = 0.*x0;
    p0 = [x0;y0;z0];
    plot3(x0,y0,z0,color);
    yaw = r.States(2,:);
    lean = r.States(3,:);
    pitch = 0.*yaw;
    angles = deg2rad([yaw;lean;pitch]);
    f = @(p,a)p + angle2dcm(a(1),a(2),a(3),'ZXY')*[0;0;3];
    p = cell2mat(cellfun(f,num2cell(p0,1),num2cell(angles,1),"uniform",0));
    plot3(p(1,:),p(2,:),p(3,:),color);
    X = [p0(1,:);p(1,:)];
    Y = [p0(2,:);p(2,:)];
    Z = [p0(3,:);p(3,:)];
    surf(X,Y,Z,"FaceColor",color,"EdgeColor","none","FaceAlpha",0.4);
    hold(fig.Children,"off");
end