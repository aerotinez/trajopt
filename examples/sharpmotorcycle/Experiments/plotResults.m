function fig = plotResults(results)
    arguments
        results (:,1) struct
    end
    fig = figure();
    tiledlayout(fig,2,3);
    arrayfun(@nexttile,1:prod(fig.Children.GridSize));
    set(fig,"Position",[100,360,640,480]);

    state_names = [
        "Offset";
        "Relative heading";
        "Lean";
        "Lateral velocity";
        "Lean rate";
        "Steering torque";
        ];

    colors = 'krb';

    arrayfun(@(r,c)helper(fig,r,state_names,c),results,colors.');
    leg_names = {'','big sports','','cruiser','','touring'};
    leg = legend(leg_names{:}, ...
        "NumColumns",3, ...
        "Location","SouthOutside", ...
        "Box","on");
    leg.Layout.Tile = 'south';
    leg.FontSize = 12;

    set(fig,"Position",[100,360,640,480]);
end

function fig = helper(fig,result,state_names,color)
    n = prod(fig.Children.GridSize);
    nx = size(result.Collocation.States,1);
    idx = nonzeros(contains(result.Collocation.Names,state_names).*(1:nx).');
    for i = 1:n
        axe = fig.Children.Children(n - i + 1);
        hold(axe,"on");
        s_collocation = result.Collocation.Progress;
        % t_collocation = result.Collocation.Time;
        x_collocation = result.Collocation.States(idx(i),:);
        scatter(s_collocation,x_collocation,30,color,"filled","Parent",axe);
        s_trajectory = result.Trajectory.Progress;
        % t_trajectory = result.Trajectory.Time;
        x_trajectory = result.Trajectory.States(idx(i),:);
        plot(s_trajectory,x_trajectory,color,"Parent",axe,"LineWidth",1.5); 
        hold(axe,"off");
        box(axe,"on");
        title(axe,result.Collocation.Names(idx(i)));
        xlabel(axe,"time (s)");
        ylabel(axe,result.Collocation.Units(idx(i)),'Interpreter','tex');
        xlim(axe,[0,s_trajectory(end)]);
    end
end