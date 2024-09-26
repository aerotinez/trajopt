function fig = plotResults(results)
    arguments
        results (:,1) struct
    end
    fig = figure();
    tiledlayout(fig,4,2);
    arrayfun(@nexttile,1:prod(fig.Children.GridSize));

    state_names = [
        "Offset";
        "Relative heading";
        "Lean";
        "Longitudinal speed"
        "Lateral speed";
        "Lean rate";
        "Rear tire lateral force";
        "Front tire lateral force";
        "Throttle torque"
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
    leg.FontSize = 18;

    set(fig,"Position",[50,100,640,850]);
end

function fig = helper(fig,result,state_names,color)
    n = prod(fig.Children.GridSize);
    nx = size(result.Collocation.States,1);
    idx = nonzeros(contains(result.Collocation.Names,state_names).*(1:nx).');
    for i = 1:n
        axe = fig.Children.Children(n - i + 1);
        axe.FontSize = 18;
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
        axe.TitleFontSizeMultiplier = 1;
        xlabel(axe,"arclength (m)","FontSize",18);
        ylabel(axe,result.Collocation.Units(idx(i)), ...
            'Interpreter','tex','FontSize',18);
        xlim(axe,[0,s_trajectory(end)]);
    end
end