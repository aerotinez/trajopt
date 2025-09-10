function fig = plot(obj,num_rows,num_cols)
    arguments
        obj (1,1) trajopt.trajectory.Trajectory;
        num_rows (1,1) double {mustBeReal,mustBeInteger,mustBePositive};
        num_cols (1,1) double {mustBeReal,mustBeInteger,mustBePositive};
    end

    fig = figure;

    tl = tiledlayout(num_rows,num_cols, ...
        'Parent',fig, ...
        'TileSpacing','compact', ...
        'Padding','compact' ...
        );

    sgtitle("Collocated trajectory",'Parent',tl,'FontSize',12);

    nx = size(obj.States,2);
    nu = size(obj.Controls,2);
    n = nx + nu;

    X = [obj.States,obj.Controls];
    [t,x,u] = interpolate(obj);
    z = [x,u];

    names = [obj.StateNames,obj.ControlNames];
    quantities = [obj.StateQuantities,obj.ControlQuantities];
    units = [obj.StateUnits,obj.ControlUnits];

    for k = 1:n
        axe = nexttile(tl,k);
        hold(axe,'on');
        plot(axe,t,z(:,k));
        scatter(axe,obj.Time,X(:,k),'filled');
        hold(axe,'off');
        box(axe,'on');
        axis(axe,'tight');
        title(axe,names(k),'FontSize',12);
        ylabel(axe,quantities(k) + " (" + units(k) + ")",'FontSize',12);
        [~,row] = ind2sub([num_cols,num_rows],k);
        if row == num_rows
            xlabel(axe,"time (s)",'FontSize',12);
        end
    end

    leg = legend('Interpolation','Nodes', ...
        'FontSize',12, ...
        'Orientation','horizontal', ...
        'Location','southoutside' ...
        );

    leg.Layout.Tile = "south";
end